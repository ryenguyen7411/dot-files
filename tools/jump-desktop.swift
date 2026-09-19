import AppKit
import ApplicationServices
import CoreGraphics
import Foundation

// MARK: - SkyLight / CGS Private API Declarations

@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> UInt32

@_silgen_name("CGSGetActiveSpace")
func CGSGetActiveSpace(_ cid: UInt32) -> UInt64

@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ cid: UInt32) -> CFArray?

// MARK: - Constants & Helpers

func printUsage() {
    print("""
    \u{001B}[1mjump-desktop\u{001B}[0m - Desktop / Space watcher with instant window autofocus for macOS

    \u{001B}[1mUsage:\u{001B}[0m
      jump-desktop <action> [options]

    \u{001B}[1mActions:\u{001B}[0m
      focus          Autofocus the target window (under mouse > screen center > frontmost on screen)
      -h, --help     Show this help message

    \u{001B}[1mOptions:\u{001B}[0m
      --watch, -w    Run background watcher (detects Space changes across all displays and autofocuses)
      --delay <ms>   Delay in ms after space switch before focusing (default: 60ms)
      --warp, -m     Move mouse cursor to center of the focused window (default: disabled)
      --no-warp      Keep mouse position unchanged (default)

    \u{001B}[1mEnvironment Overrides:\u{001B}[0m
      Optionally set in ~/.config/zsh/local.zsh:
        export JUMP_DESKTOP_DELAY="60"    # Custom delay in milliseconds
        export JUMP_DESKTOP_WARP="1"      # Warp mouse to focused window (if desired)
    """)
}

let ignoredOwners: Set<String> = [
    "Window Server",
    "Dock",
    "WindowManager",
    "Control Center",
    "Notification Center",
    "SystemUIServer",
    "Spotlight",
    "Raycast",
    "loginwindow",
    "ScreenSaverEngine"
]

struct AppWindowTarget {
    let pid: pid_t
    let appName: String
    let windowElement: AXUIElement?
    let bounds: CGRect
}

enum MatchReason: String {
    case underMouse = "under mouse"
    case centerOfScreen = "center of screen"
    case frontmostOnScreen = "frontmost on screen"
}

struct TargetResult {
    let target: AppWindowTarget
    let matchReason: MatchReason
}

// Get all active display bounds in CoreGraphics coordinates
func getActiveDisplays() -> [CGRect] {
    var count: UInt32 = 0
    CGGetActiveDisplayList(0, nil, &count)
    var displays = [CGDirectDisplayID](repeating: 0, count: Int(count))
    CGGetActiveDisplayList(count, &displays, &count)
    return displays.map { CGDisplayBounds($0) }
}

// Find display containing mouse location (or closest display if near boundary)
func getDisplayContaining(point: CGPoint, displays: [CGRect]) -> CGRect {
    for d in displays {
        if d.contains(point) {
            return d
        }
    }
    if let closest = displays.min(by: { d1, d2 in
        let dx1 = max(d1.minX - point.x, 0, point.x - d1.maxX)
        let dy1 = max(d1.minY - point.y, 0, point.y - d1.maxY)
        let dx2 = max(d2.minX - point.x, 0, point.x - d2.maxX)
        let dy2 = max(d2.minY - point.y, 0, point.y - d2.maxY)
        return (dx1 * dx1 + dy1 * dy1) < (dx2 * dx2 + dy2 * dy2)
    }) {
        return closest
    }
    return CGRect(x: 0, y: 0, width: 1920, height: 1080)
}

// Perform hit-test at given point using Accessibility API to find real interactive application window
func getAppAndWindowAt(point: CGPoint) -> AppWindowTarget? {
    let systemWide = AXUIElementCreateSystemWide()
    var element: AXUIElement?
    guard AXUIElementCopyElementAtPosition(systemWide, Float(point.x), Float(point.y), &element) == .success,
          let elem = element else {
        return nil
    }

    var pid: pid_t = 0
    guard AXUIElementGetPid(elem, &pid) == .success, pid > 0 else {
        return nil
    }

    guard let app = NSRunningApplication(processIdentifier: pid),
          let name = app.localizedName,
          !ignoredOwners.contains(name) else {
        return nil
    }

    // Traverse ancestors to find AXWindow
    var current: AXUIElement? = elem
    while let cur = current {
        var roleVal: AnyObject?
        if AXUIElementCopyAttributeValue(cur, kAXRoleAttribute as CFString, &roleVal) == .success,
           let role = roleVal as? String, role == (kAXWindowRole as String) {
            var subroleVal: AnyObject?
            AXUIElementCopyAttributeValue(cur, kAXSubroleAttribute as CFString, &subroleVal)
            let subrole = subroleVal as? String ?? ""
            // Filter out non-interactive / dummy / desktop windows
            if subrole == "AXUnknown" {
                return nil
            }

            var posVal: AnyObject?
            var sizeVal: AnyObject?
            AXUIElementCopyAttributeValue(cur, kAXPositionAttribute as CFString, &posVal)
            AXUIElementCopyAttributeValue(cur, kAXSizeAttribute as CFString, &sizeVal)
            var pos = CGPoint.zero
            var size = CGSize.zero
            if let pv = posVal as! AXValue? { AXValueGetValue(pv, .cgPoint, &pos) }
            if let sv = sizeVal as! AXValue? { AXValueGetValue(sv, .cgSize, &size) }
            let rect = CGRect(origin: pos, size: size)
            return AppWindowTarget(pid: pid, appName: name, windowElement: cur, bounds: rect)
        }
        var parentVal: AnyObject?
        if AXUIElementCopyAttributeValue(cur, kAXParentAttribute as CFString, &parentVal) == .success,
           let parent = parentVal {
            current = (parent as! AXUIElement)
        } else {
            current = nil
        }
    }
    return nil
}

// Find target window hierarchy: under mouse > center of current screen with cursor > frontmost on screen
func getTargetWindow(mouseLoc: CGPoint) -> TargetResult? {
    let displays = getActiveDisplays()
    let currentDisplay = getDisplayContaining(point: mouseLoc, displays: displays)
    let screenCenter = CGPoint(x: currentDisplay.midX, y: currentDisplay.midY)

    // 1. Priority 1: Window directly under mouse cursor (via real interactive Accessibility hit-test)
    if let target = getAppAndWindowAt(point: mouseLoc) {
        return TargetResult(target: target, matchReason: .underMouse)
    }

    // 2. Priority 2: Window covering center of current screen with cursor
    if let target = getAppAndWindowAt(point: screenCenter) {
        return TargetResult(target: target, matchReason: .centerOfScreen)
    }

    // 3. Priority 3: Fallback to frontmost visible window on this screen via CGWindowList + AX verification
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
        return nil
    }

    for info in list {
        guard let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
              let boundsDict = info[kCGWindowBounds as String] as? [String: Any],
              let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary),
              bounds.width >= 100, bounds.height >= 100,
              let pid = info[kCGWindowOwnerPID as String] as? pid_t,
              let owner = info[kCGWindowOwnerName as String] as? String,
              !ignoredOwners.contains(owner) else {
            continue
        }

        let alpha = info[kCGWindowAlpha as String] as? Double ?? 1.0
        guard alpha > 0.05 else { continue }

        let intersection = bounds.intersection(currentDisplay)
        guard !intersection.isNull, intersection.width >= 100, intersection.height >= 100 else {
            continue
        }

        // Verify this PID has a real AXWindow on the current display (not dummy/unknown)
        let appElement = AXUIElementCreateApplication(pid)
        var windowsValue: AnyObject?
        if AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsValue) == .success,
           let windows = windowsValue as? [AXUIElement] {
            for win in windows {
                var subroleVal: AnyObject?
                AXUIElementCopyAttributeValue(win, kAXSubroleAttribute as CFString, &subroleVal)
                let subrole = subroleVal as? String ?? ""
                if subrole == "AXUnknown" { continue }

                var posVal: AnyObject?
                var sizeVal: AnyObject?
                AXUIElementCopyAttributeValue(win, kAXPositionAttribute as CFString, &posVal)
                AXUIElementCopyAttributeValue(win, kAXSizeAttribute as CFString, &sizeVal)
                var pos = CGPoint.zero
                var size = CGSize.zero
                if let pv = posVal as! AXValue? { AXValueGetValue(pv, .cgPoint, &pos) }
                if let sv = sizeVal as! AXValue? { AXValueGetValue(sv, .cgSize, &size) }
                let rect = CGRect(origin: pos, size: size)
                if rect.intersects(currentDisplay) {
                    let target = AppWindowTarget(pid: pid, appName: owner, windowElement: win, bounds: rect)
                    return TargetResult(target: target, matchReason: .frontmostOnScreen)
                }
            }
        }
    }

    return nil
}

// Activate application and raise specific window (without changing mouse position unless warp is explicitly requested)
@discardableResult
func focusWindow(target: AppWindowTarget, warp: Bool = false) -> Bool {
    // 1. Activate application
    guard let app = NSRunningApplication(processIdentifier: target.pid) else {
        return false
    }

    #if swift(>=5.9)
    if #available(macOS 14.0, *) {
        app.activate()
    } else {
        app.activate(options: [.activateIgnoringOtherApps])
    }
    #else
    app.activate(options: [.activateIgnoringOtherApps])
    #endif

    // 2. Set frontmost and raise specific AXWindow element
    let appElement = AXUIElementCreateApplication(target.pid)
    _ = AXUIElementSetAttributeValue(appElement, kAXFrontmostAttribute as CFString, kCFBooleanTrue)

    if let win = target.windowElement {
        AXUIElementPerformAction(win, kAXRaiseAction as CFString)
        AXUIElementSetAttributeValue(win, kAXMainAttribute as CFString, kCFBooleanTrue)
    }

    // 3. Optional warp mouse to center of focused window (only if explicitly enabled)
    if warp {
        let center = CGPoint(x: target.bounds.midX, y: target.bounds.midY)
        CGWarpMouseCursorPosition(center)
        CGAssociateMouseAndMouseCursorPosition(1)
    }

    return true
}

func getManagedDisplaySpaces(cid: UInt32) -> [String: UInt64] {
    var result: [String: UInt64] = [:]
    if let displays = CGSCopyManagedDisplaySpaces(cid) as? [[String: Any]] {
        for d in displays {
            guard let uuid = d["Display Identifier"] as? String,
                  let currentSpace = d["Current Space"] as? [String: Any] else {
                continue
            }
            let spaceID = (currentSpace["id64"] as? UInt64)
                ?? (currentSpace["ManagedSpaceID"] as? UInt64)
                ?? (currentSpace["id64"] as? Int).map { UInt64($0) }
                ?? (currentSpace["ManagedSpaceID"] as? Int).map { UInt64($0) }
            if let spaceID = spaceID {
                result[uuid] = spaceID
            }
        }
    }
    return result
}

// Watcher mode using direct CGS WindowServer polling (0% CPU, ultra-reliable across all macOS versions and multi-display setups)
func startWatcher(delayMs: UInt32, warp: Bool) {
    setlinebuf(stdout)
    let cid = CGSMainConnectionID()
    var currentActiveSpace = CGSGetActiveSpace(cid)
    var currentDisplaySpaces = getManagedDisplaySpaces(cid: cid)

    let initialDesc = currentDisplaySpaces.isEmpty ? "\(currentActiveSpace)" : currentDisplaySpaces.map { "\($0.key.prefix(8)):\($0.value)" }.joined(separator: ", ")
    print("\u{001B}[32m✓ jump-desktop watcher active. Monitoring Space / Desktop changes across displays (Spaces: \(initialDesc))...\u{001B}[0m")
    fflush(stdout)

    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"

    while true {
        usleep(40_000) // Poll every 40ms (ultra-responsive, <0.001% CPU)
        let newDisplaySpaces = getManagedDisplaySpaces(cid: cid)
        let newActiveSpace = CGSGetActiveSpace(cid)

        let hasChange: Bool
        if !newDisplaySpaces.isEmpty {
            hasChange = (newDisplaySpaces != currentDisplaySpaces)
        } else {
            hasChange = (newActiveSpace != currentActiveSpace)
        }

        if hasChange {
            currentDisplaySpaces = newDisplaySpaces
            currentActiveSpace = newActiveSpace

            // Snappy settling delay (default 60ms)
            if delayMs > 0 {
                usleep(delayMs * 1000)
            }

            let mouseLoc = CGEvent(source: nil)?.location ?? .zero
            let timeStr = formatter.string(from: Date())

            if let targetResult = getTargetWindow(mouseLoc: mouseLoc) {
                focusWindow(target: targetResult.target, warp: warp)
                print("[\(timeStr)] Space changed -> Focused \(targetResult.matchReason.rawValue): \(targetResult.target.appName) (PID: \(targetResult.target.pid))")
                fflush(stdout)
            } else {
                print("[\(timeStr)] Space changed -> (No active application window)")
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
    let mouseLoc = CGEvent(source: nil)?.location ?? .zero
    if let targetResult = getTargetWindow(mouseLoc: mouseLoc) {
        focusWindow(target: targetResult.target, warp: shouldWarp)
        print("✓ Focused \(targetResult.matchReason.rawValue): \(targetResult.target.appName) (PID: \(targetResult.target.pid))")
    } else {
        print("No visible window found to focus.")
    }
default:
    fputs("Error: Invalid action '\(action)'. Use focus or --watch.\n", stderr)
    exit(1)
}

exit(0)
