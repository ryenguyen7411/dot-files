import AppKit
import ApplicationServices
import CoreGraphics
import Foundation

// MARK: - Helper Functions

func printUsage() {
    print("""
    \u{001B}[1mjump-display\u{001B}[0m - Teleport mouse cursor across monitors instantly

    \u{001B}[1mUsage:\u{001B}[0m
      jump-display <target> [options]

    \u{001B}[1mTargets:\u{001B}[0m
      1, 2, 3...     Jump to specific monitor (sorted physically left-to-right)
      next, cycle    Jump to next monitor relative to current cursor position
      prev           Jump to previous monitor
      primary        Jump to primary monitor (origin 0,0)
      list           List all detected monitors, resolutions, and current cursor location
      -h, --help     Show this help message

    \u{001B}[1mOptions:\u{001B}[0m
      --focus, -f    Automatically focus / activate the top window under the target destination
      --click, -c    Simulate a left-click at the target destination to guarantee input focus
      --no-focus     Do not change window focus (default)

    \u{001B}[1mEnvironment Overrides:\u{001B}[0m
      Optionally set in ~/.config/zsh/local.zsh to override coordinates or default behavior:
        export DISPLAY_1_COORDS="960,540"
        export DISPLAY_2_COORDS="2880,540"
        export JUMP_DISPLAY_AUTO_FOCUS="1"   # Always focus window under destination
    """)
}

func getPrimaryScreenHeight(screens: [NSScreen]) -> CGFloat {
    return screens.first(where: { $0.frame.origin == .zero })?.frame.height ?? (screens.first?.frame.height ?? 1080.0)
}

func cocoaToCoreGraphics(point: CGPoint, primaryHeight: CGFloat) -> CGPoint {
    return CGPoint(x: point.x, y: primaryHeight - point.y)
}

func getScreenCenterCG(screen: NSScreen, primaryHeight: CGFloat) -> CGPoint {
    let cocoaCenterX = screen.frame.origin.x + screen.frame.width / 2.0
    let cocoaCenterY = screen.frame.origin.y + screen.frame.height / 2.0
    return cocoaToCoreGraphics(point: CGPoint(x: cocoaCenterX, y: cocoaCenterY), primaryHeight: primaryHeight)
}

func parseCoordinates(from string: String) -> CGPoint? {
    let parts = string.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    guard parts.count == 2,
          let x = Double(parts[0]),
          let y = Double(parts[1]) else {
        return nil
    }
    return CGPoint(x: x, y: y)
}

func activateWindowUnder(point: CGPoint) {
    // 1. Fast Accessibility check
    let systemWide = AXUIElementCreateSystemWide()
    var element: AXUIElement?
    if AXUIElementCopyElementAtPosition(systemWide, Float(point.x), Float(point.y), &element) == .success,
       let elem = element {
        var pid: pid_t = 0
        if AXUIElementGetPid(elem, &pid) == .success && pid > 0 {
            if let app = NSRunningApplication(processIdentifier: pid) {
                #if swift(>=5.9)
                if #available(macOS 14.0, *) {
                    app.activate()
                } else {
                    app.activate(options: [.activateIgnoringOtherApps])
                }
                #else
                app.activate(options: [.activateIgnoringOtherApps])
                #endif
                return
            }
        }
    }

    // 2. Fallback to CGWindowList check
    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let windowListInfo = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
        return
    }

    for info in windowListInfo {
        guard let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
              let boundsDict = info[kCGWindowBounds as String] as? [String: Any],
              let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary),
              bounds.contains(point),
              let pid = info[kCGWindowOwnerPID as String] as? pid_t else {
            continue
        }

        if let app = NSRunningApplication(processIdentifier: pid) {
            #if swift(>=5.9)
            if #available(macOS 14.0, *) {
                app.activate()
            } else {
                app.activate(options: [.activateIgnoringOtherApps])
            }
            #else
            app.activate(options: [.activateIgnoringOtherApps])
            #endif
            return
        }
    }
}

func postSyntheticClick(at point: CGPoint) {
    guard let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left),
          let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else {
        return
    }
    mouseDown.post(tap: .cghidEventTap)
    mouseUp.post(tap: .cghidEventTap)
}

// MARK: - Main Logic

let rawArgs = CommandLine.arguments

if rawArgs.count < 2 || rawArgs.contains("-h") || rawArgs.contains("--help") {
    printUsage()
    exit(0)
}

var shouldFocus = ProcessInfo.processInfo.environment["JUMP_DISPLAY_AUTO_FOCUS"] == "1"
var shouldClick = false
var positionalArgs: [String] = []

for arg in rawArgs.dropFirst() {
    switch arg.lowercased() {
    case "--focus", "-f":
        shouldFocus = true
    case "--no-focus":
        shouldFocus = false
    case "--click", "-c":
        shouldClick = true
    default:
        positionalArgs.append(arg)
    }
}

guard let targetRaw = positionalArgs.first else {
    printUsage()
    exit(0)
}

let targetArg = targetRaw.lowercased()

let screens = NSScreen.screens
guard !screens.isEmpty else {
    fputs("Error: No displays detected.\n", stderr)
    exit(1)
}

// Sort screens physically from left to right, then top to bottom
let sortedScreens = screens.sorted {
    if $0.frame.origin.x != $1.frame.origin.x {
        return $0.frame.origin.x < $1.frame.origin.x
    }
    return $0.frame.origin.y > $1.frame.origin.y
}

let primaryHeight = getPrimaryScreenHeight(screens: screens)
let currentMouseCocoa = NSEvent.mouseLocation
let currentMouseCG = cocoaToCoreGraphics(point: currentMouseCocoa, primaryHeight: primaryHeight)

// Find which sorted screen the mouse is currently on
var currentScreenIndex: Int = 0
for (index, screen) in sortedScreens.enumerated() {
    if screen.frame.contains(currentMouseCocoa) {
        currentScreenIndex = index
        break
    }
}

// Handle 'list' command
if targetArg == "list" {
    print("\u{001B}[1mConnected Displays (\(sortedScreens.count)):\u{001B}[0m")
    for (index, screen) in sortedScreens.enumerated() {
        let displayNum = index + 1
        let centerCG = getScreenCenterCG(screen: screen, primaryHeight: primaryHeight)
        let isCurrent = (index == currentScreenIndex)
        let currentMarker = isCurrent ? " \u{001B}[32m[Current Cursor]\u{001B}[0m" : ""
        let isPrimary = (screen.frame.origin == .zero) ? " (Primary)" : ""

        print("  Display \(displayNum)\(isPrimary):")
        print("    Resolution: \(Int(screen.frame.width))x\(Int(screen.frame.height)) at origin (\(Int(screen.frame.origin.x)), \(Int(screen.frame.origin.y)))")
        print("    Center (CG): (\(Int(centerCG.x)), \(Int(centerCG.y)))\(currentMarker)")

        if let envOverride = ProcessInfo.processInfo.environment["DISPLAY_\(displayNum)_COORDS"] {
            print("    Override (Env): \(envOverride)")
        }
    }
    exit(0)
}

var targetPoint: CGPoint?

// 1. Check if numeric display index (1, 2, 3...)
if let displayNum = Int(targetArg), displayNum >= 1 {
    // Check environment variable override (e.g. DISPLAY_1_COORDS="1920,540")
    if let envOverride = ProcessInfo.processInfo.environment["DISPLAY_\(displayNum)_COORDS"],
       let point = parseCoordinates(from: envOverride) {
        targetPoint = point
    } else {
        let targetIndex = min(max(displayNum - 1, 0), sortedScreens.count - 1)
        let targetScreen = sortedScreens[targetIndex]
        targetPoint = getScreenCenterCG(screen: targetScreen, primaryHeight: primaryHeight)
    }
} else if targetArg == "next" || targetArg == "cycle" {
    let nextIndex = (currentScreenIndex + 1) % sortedScreens.count
    let targetScreen = sortedScreens[nextIndex]
    let displayNum = nextIndex + 1
    if let envOverride = ProcessInfo.processInfo.environment["DISPLAY_\(displayNum)_COORDS"],
       let point = parseCoordinates(from: envOverride) {
        targetPoint = point
    } else {
        targetPoint = getScreenCenterCG(screen: targetScreen, primaryHeight: primaryHeight)
    }
} else if targetArg == "prev" || targetArg == "previous" {
    let prevIndex = (currentScreenIndex - 1 + sortedScreens.count) % sortedScreens.count
    let targetScreen = sortedScreens[prevIndex]
    let displayNum = prevIndex + 1
    if let envOverride = ProcessInfo.processInfo.environment["DISPLAY_\(displayNum)_COORDS"],
       let point = parseCoordinates(from: envOverride) {
        targetPoint = point
    } else {
        targetPoint = getScreenCenterCG(screen: targetScreen, primaryHeight: primaryHeight)
    }
} else if targetArg == "primary" {
    let primaryScreen = screens.first(where: { $0.frame.origin == .zero }) ?? screens[0]
    targetPoint = getScreenCenterCG(screen: primaryScreen, primaryHeight: primaryHeight)
} else {
    fputs("Error: Invalid target '\(targetArg)'. Use 1, 2, 3, next, prev, primary, or list.\n", stderr)
    exit(1)
}

guard let destination = targetPoint else {
    fputs("Error: Failed to determine target point.\n", stderr)
    exit(1)
}

// Teleport mouse cursor
CGWarpMouseCursorPosition(destination)
CGAssociateMouseAndMouseCursorPosition(1)

// Auto-focus application / window under cursor
if shouldFocus {
    activateWindowUnder(point: destination)
}

// Click if requested
if shouldClick {
    postSyntheticClick(at: destination)
}

exit(0)
