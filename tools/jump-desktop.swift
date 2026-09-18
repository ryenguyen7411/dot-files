import AppKit
import ApplicationServices
import CoreGraphics
import Foundation

// MARK: - SkyLight / CGS Private API Declarations

@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> UInt32

@_silgen_name("CGSGetActiveSpace")
func CGSGetActiveSpace(_ cid: UInt32) -> UInt64

// MARK: - Constants & Helpers

func printUsage() {
    print("""
    \u{001B}[1mjump-desktop\u{001B}[0m - Desktop / Space watcher with instant window autofocus for macOS

    \u{001B}[1mUsage:\u{001B}[0m
      jump-desktop <action> [options]

    \u{001B}[1mActions:\u{001B}[0m
      focus          Autofocus the center/top window on the current Desktop right now
      -h, --help     Show this help message

    \u{001B}[1mOptions:\u{001B}[0m
      --watch, -w    Run background watcher (detects Space changes via WindowServer and autofocuses)
      --delay <ms>   Delay in ms after space switch before focusing (default: 60ms)
      --warp, -m     Move mouse cursor to center of the focused window (default: disabled)
      --no-warp      Keep mouse position unchanged (default)

    \u{001B}[1mEnvironment Overrides:\u{001B}[0m
      Optionally set in ~/.config/zsh/local.zsh:
        export JUMP_DESKTOP_DELAY="60"    # Custom delay in milliseconds
        export JUMP_DESKTOP_WARP="1"      # Warp mouse to focused window (if desired)
    """)
}

// Convert point from Cocoa to CoreGraphics coordinates
func getPrimaryScreenHeight(screens: [NSScreen]) -> CGFloat {
    return screens.first(where: { $0.frame.origin == .zero })?.frame.height ?? (screens.first?.frame.height ?? 1080.0)
}

// Find window at center of current screen (or frontmost window on that screen)
func getCenterWindowInfo() -> (pid: pid_t, owner: String, bounds: CGRect)? {
    let screens = NSScreen.screens
    guard let mainScreen = NSScreen.main ?? screens.first else { return nil }
    let primaryHeight = getPrimaryScreenHeight(screens: screens)
    let mouseLoc = NSEvent.mouseLocation

    // Target screen under mouse cursor, or primary screen
    let targetScreen = screens.first(where: { $0.frame.contains(mouseLoc) }) ?? mainScreen
    let screenCG = CGRect(
        x: targetScreen.frame.origin.x,
        y: primaryHeight - (targetScreen.frame.origin.y + targetScreen.frame.height),
        width: targetScreen.frame.width,
        height: targetScreen.frame.height
    )
    let screenCenter = CGPoint(x: screenCG.midX, y: screenCG.midY)

    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
        return nil
    }

    let ignoredOwners: Set<String> = [
        "Window Server",
        "Dock",
        "WindowManager",
        "Control Center",
        "Notification Center",
        "SystemUIServer",
        "Spotlight",
        "Raycast"
    ]

    var candidates: [(pid: pid_t, owner: String, bounds: CGRect)] = []

    for info in list {
        guard let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
              let boundsDict = info[kCGWindowBounds as String] as? [String: Any],
              let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary),
              bounds.width > 120, bounds.height > 120,
              bounds.origin.x >= 0, bounds.origin.y >= 0, // Filter out Stage Manager offscreen previews
              bounds.origin.x < screenCG.maxX, bounds.origin.y < screenCG.maxY,
              let pid = info[kCGWindowOwnerPID as String] as? pid_t,
              let owner = info[kCGWindowOwnerName as String] as? String,
              !ignoredOwners.contains(owner) else {
            continue
        }
        candidates.append((pid, owner, bounds))
    }

    // 1. Prioritize topmost window covering the center of the screen
    if let centerWindow = candidates.first(where: { $0.bounds.contains(screenCenter) }) {
        return centerWindow
    }

    // 2. Fallback to frontmost visible window on this screen
    return candidates.first
}

// Activate application and raise specific window (without changing mouse position unless warp is explicitly requested)
@discardableResult
func focusWindow(warp: Bool = false) -> Bool {
    guard let target = getCenterWindowInfo() else {
        return false
    }

    // 1. Activate application
    if let app = NSRunningApplication(processIdentifier: target.pid) {
        #if swift(>=5.9)
        if #available(macOS 14.0, *) {
            _ = app.activate(options: [.activateIgnoringOtherApps])
        } else {
            _ = app.activate(options: [.activateIgnoringOtherApps])
        }
        #else
        _ = app.activate(options: [.activateIgnoringOtherApps])
        #endif
    }

    // 2. Set frontmost and raise specific AXWindow element
    let appElement = AXUIElementCreateApplication(target.pid)
    _ = AXUIElementSetAttributeValue(appElement, kAXFrontmostAttribute as CFString, kCFBooleanTrue)

    var windowsValue: AnyObject?
    if AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue) == .success,
       let windows = windowsValue as? [AXUIElement] {
        for win in windows {
            var posVal: AnyObject?
            var sizeVal: AnyObject?
            if AXUIElementCopyAttributeValue(win, kAXPositionAttribute as CFString, &posVal) == .success,
               AXUIElementCopyAttributeValue(win, kAXSizeAttribute as CFString, &sizeVal) == .success {
                var pos = CGPoint.zero
                var size = CGSize.zero
                if AXValueGetValue(posVal as! AXValue, .cgPoint, &pos),
                   AXValueGetValue(sizeVal as! AXValue, .cgSize, &size) {
                    let rect = CGRect(origin: pos, size: size)
                    if rect.intersects(target.bounds) {
                        AXUIElementPerformAction(win, kAXRaiseAction as CFString)
                        AXUIElementSetAttributeValue(win, kAXMainAttribute as CFString, kCFBooleanTrue)
                        break
                    }
                }
            }
        }
    }

    // 3. Optional warp mouse to center of focused window (only if explicitly enabled)
    if warp {
        let center = CGPoint(x: target.bounds.midX, y: target.bounds.midY)
        CGWarpMouseCursorPosition(center)
        CGAssociateMouseAndMouseCursorPosition(1)
    }

    return true
}

// Watcher mode using direct CGS WindowServer polling (0% CPU, ultra-reliable across all macOS versions)
func startWatcher(delayMs: UInt32, warp: Bool) {
    setlinebuf(stdout)
    let cid = CGSMainConnectionID()
    var currentSpace = CGSGetActiveSpace(cid)

    print("\u{001B}[32m✓ jump-desktop watcher active. Monitoring Space / Desktop changes (Initial Space ID: \(currentSpace))...\u{001B}[0m")
    fflush(stdout)

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"

    while true {
        usleep(40_000) // Poll every 40ms (ultra-responsive, <0.001% CPU)
        let newSpace = CGSGetActiveSpace(cid)
        if newSpace != currentSpace {
            let oldSpace = currentSpace
            currentSpace = newSpace

            // Snappy settling delay (default 60ms)
            if delayMs > 0 {
                usleep(delayMs * 1000)
            }

            if let target = getCenterWindowInfo() {
                focusWindow(warp: warp)
                let timeStr = formatter.string(from: Date())
                print("[\(timeStr)] Space changed (\(oldSpace) -> \(newSpace)) -> Focused center: \(target.owner) (PID: \(target.pid))")
                fflush(stdout)
            } else {
                let timeStr = formatter.string(from: Date())
                print("[\(timeStr)] Space changed (\(oldSpace) -> \(newSpace)) -> (No active application window)")
                fflush(stdout)
            }
        }
    }
}

// MARK: - CLI Entrypoint

let rawArgs = CommandLine.arguments

if rawArgs.count < 2 || rawArgs.contains("-h") || rawArgs.contains("--help") {
    printUsage()
    exit(0)
}

var shouldWarp = ProcessInfo.processInfo.environment["JUMP_DESKTOP_WARP"] == "1"
var customDelayMs: UInt32? = {
    if let env = ProcessInfo.processInfo.environment["JUMP_DESKTOP_DELAY"], let val = UInt32(env) {
        return val
    }
    return nil
}()

var isWatchMode = false
var positionalArgs: [String] = []

var i = 1
while i < rawArgs.count {
    let arg = rawArgs[i]
    switch arg.lowercased() {
    case "--watch", "-w":
        isWatchMode = true
    case "--warp", "-m":
        shouldWarp = true
    case "--no-warp":
        shouldWarp = false
    case "--delay":
        if i + 1 < rawArgs.count, let val = UInt32(rawArgs[i + 1]) {
            customDelayMs = val
            i += 1
        }
    default:
        positionalArgs.append(arg)
    }
    i += 1
}

if isWatchMode {
    let delay = customDelayMs ?? 60
    startWatcher(delayMs: delay, warp: shouldWarp)
    exit(0)
}

guard let action = positionalArgs.first?.lowercased() else {
    printUsage()
    exit(0)
}

switch action {
    case "focus":
        if let target = getCenterWindowInfo() {
            focusWindow(warp: shouldWarp)
            print("✓ Focused center window: \(target.owner) (PID: \(target.pid))")
        } else {
            print("No visible window found to focus.")
        }
    default:
        fputs("Error: Invalid action '\(action)'. Use focus or --watch.\n", stderr)
        exit(1)
}

exit(0)
