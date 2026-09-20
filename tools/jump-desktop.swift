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
      focus          Autofocus the target window (under mouse > center of screen > frontmost on screen)
      -h, --help     Show this help message

    \u{001B}[1mOptions:\u{001B}[0m
      --watch, -w    Run background watcher (detects Space changes across all displays and autofocuses)
      --delay <ms>   Delay in ms after space switch before focusing (default: 80ms)
      --warp, -m     Move mouse cursor to center of the focused window (default: disabled)
      --no-warp      Keep mouse position unchanged (default)
      --click, -c    Simulate a left-click at mouse location to guarantee input focus
      --no-click     Do not simulate mouse click (default)

    \u{001B}[1mEnvironment Overrides:\u{001B}[0m
      Optionally set in ~/.config/zsh/local.zsh:
        export JUMP_DESKTOP_DELAY="80"    # Custom delay in milliseconds
        export JUMP_DESKTOP_WARP="1"      # Warp mouse to focused window (if desired)
        export JUMP_DESKTOP_CLICK="1"     # Simulate left-click to guarantee input focus
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
    "ScreenSaverEngine",
    "TextInputMenuAgent",
    "TextInputSwitcher",
    "ViewBridgeAuxiliary",
    "talagent"
]

struct AppTarget {
    let pid: pid_t
    let appName: String
    let bounds: CGRect
    let windowElement: AXUIElement?
}

// Request Accessibility permissions if not already granted
func ensureAccessibilityPrompt() {
    if !AXIsProcessTrusted() {
        let promptKey = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [promptKey: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }
}

// Get primary screen height (for Cocoa -> CoreGraphics coordinate conversion)
func getPrimaryScreenHeight(screens: [NSScreen]) -> CGFloat {
    return screens.first(where: { $0.frame.origin == .zero })?.frame.height ?? (screens.first?.frame.height ?? 1080.0)
}

// Convert NSScreen frame to CoreGraphics coordinate space (origin at top-left of primary display)
func getScreenBoundsCG(screen: NSScreen, primaryHeight: CGFloat) -> CGRect {
    let cgY = primaryHeight - screen.frame.origin.y - screen.frame.height
    return CGRect(x: screen.frame.origin.x, y: cgY, width: screen.frame.width, height: screen.frame.height)
}

// Get all active display bounds in CoreGraphics coordinates
func getActiveDisplays() -> [CGRect] {
    var count: UInt32 = 0
    if CGGetOnlineDisplayList(0, nil, &count) == .success && count > 0 {
        var displays = [CGDirectDisplayID](repeating: 0, count: Int(count))
        if CGGetOnlineDisplayList(count, &displays, &count) == .success {
            let active = displays.filter { CGDisplayIsActive($0) != 0 }.map { CGDisplayBounds($0) }
            if !active.isEmpty {
                return active
            }
        }
    }
    let screens = NSScreen.screens
    if !screens.isEmpty {
        let primaryHeight = getPrimaryScreenHeight(screens: screens)
        return screens.map { getScreenBoundsCG(screen: $0, primaryHeight: primaryHeight) }
    }
    return [CGRect(x: 0, y: 0, width: 2560, height: 1440)]
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

func postSyntheticClick(at point: CGPoint) {
    guard let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: point, mouseButton: .left),
          let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: point, mouseButton: .left) else {
        return
    }
    mouseDown.post(tap: .cghidEventTap)
    mouseUp.post(tap: .cghidEventTap)
}

func getAXWindows(appElement: AXUIElement) -> [AXUIElement] {
    var windows: [AXUIElement] = []
    var winVal: AnyObject?
    if AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &winVal) == .success,
       let list = winVal as? [AXUIElement], !list.isEmpty {
        windows.append(contentsOf: list)
    }

    // Fallback: check kAXMainWindowAttribute (crucial for GLFW/kitty, Electron/Cursor, etc.)
    var mainVal: AnyObject?
    if AXUIElementCopyAttributeValue(appElement, kAXMainWindowAttribute as CFString, &mainVal) == .success,
       let mainWin = mainVal {
        let mw = mainWin as! AXUIElement
        if !windows.contains(where: { CFEqual($0, mw) }) {
            windows.append(mw)
        }
    }

    // Fallback: check kAXFocusedWindowAttribute
    var focusedVal: AnyObject?
    if AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedVal) == .success,
       let focusedWin = focusedVal {
        let fw = focusedWin as! AXUIElement
        if !windows.contains(where: { CFEqual($0, fw) }) {
            windows.append(fw)
        }
    }

    return windows
}

// Perform interactive hit-test via Accessibility API
func findAXWindow(sys: AXUIElement, point: CGPoint) -> AppTarget? {
    var element: AXUIElement?
    guard AXUIElementCopyElementAtPosition(sys, Float(point.x), Float(point.y), &element) == .success,
          let elem = element else {
        return nil
    }
    var pid: pid_t = 0
    guard AXUIElementGetPid(elem, &pid) == .success, pid > 0 else { return nil }
    guard let app = NSRunningApplication(processIdentifier: pid),
          let name = app.localizedName,
          !ignoredOwners.contains(name) else { return nil }

    var current: AXUIElement? = elem
    while let cur = current {
        var roleVal: AnyObject?
        if AXUIElementCopyAttributeValue(cur, kAXRoleAttribute as CFString, &roleVal) == .success,
           let role = roleVal as? String, role == (kAXWindowRole as String) {
            var subVal: AnyObject?
            AXUIElementCopyAttributeValue(cur, kAXSubroleAttribute as CFString, &subVal)
            if (subVal as? String) == "AXUnknown" { return nil }
            var posVal: AnyObject?
            var sizeVal: AnyObject?
            AXUIElementCopyAttributeValue(cur, kAXPositionAttribute as CFString, &posVal)
            AXUIElementCopyAttributeValue(cur, kAXSizeAttribute as CFString, &sizeVal)
            var pos = CGPoint.zero
            var size = CGSize.zero
            if let pv = posVal as! AXValue? { AXValueGetValue(pv, .cgPoint, &pos) }
            if let sv = sizeVal as! AXValue? { AXValueGetValue(sv, .cgSize, &size) }
            return AppTarget(pid: pid, appName: name, bounds: CGRect(origin: pos, size: size), windowElement: cur)
        }
        var pVal: AnyObject?
        if AXUIElementCopyAttributeValue(cur, kAXParentAttribute as CFString, &pVal) == .success,
           let p = pVal {
            current = (p as! AXUIElement)
        } else {
            current = nil
        }
    }
    return nil
}

// Find target window hierarchy: under mouse > center of current screen with cursor > frontmost on screen
func getTarget(mouseLoc: CGPoint) -> (target: AppTarget, reason: String)? {
    let displays = getActiveDisplays()
    let currentDisplay = getDisplayContaining(point: mouseLoc, displays: displays)
    let screenCenter = CGPoint(x: currentDisplay.midX, y: currentDisplay.midY)
    let isAXTrusted = AXIsProcessTrusted()

    let options: CGWindowListOption = [.optionOnScreenOnly, .excludeDesktopElements]
    guard let list = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] else {
        return nil
    }

    // Helper to evaluate a candidate window dictionary from CGWindowList
    func checkWindowCandidate(info: [String: Any]) -> (target: AppTarget, bounds: CGRect)? {
        guard let layer = info[kCGWindowLayer as String] as? Int, layer == 0,
              let boundsDict = info[kCGWindowBounds as String] as? [String: Any],
              let bounds = CGRect(dictionaryRepresentation: boundsDict as CFDictionary),
              bounds.width >= 100, bounds.height >= 100,
              let pid = info[kCGWindowOwnerPID as String] as? pid_t,
              let owner = info[kCGWindowOwnerName as String] as? String,
              !ignoredOwners.contains(owner) else {
            return nil
        }
        let alpha = info[kCGWindowAlpha as String] as? Double ?? 1.0
        guard alpha > 0.05 else { return nil }

        // Must intersect current display significantly
        let intersection = bounds.intersection(currentDisplay)
        guard !intersection.isNull, intersection.width >= 50, intersection.height >= 50 else {
            return nil
        }

        // Filter out invisible helper/utility windows
        let appElem = AXUIElementCreateApplication(pid)
        let wins = getAXWindows(appElement: appElem)
        var matchedAXWindow: AXUIElement?

        if !wins.isEmpty {
            for w in wins {
                var posVal: AnyObject?
                var sizeVal: AnyObject?
                AXUIElementCopyAttributeValue(w, kAXPositionAttribute as CFString, &posVal)
                AXUIElementCopyAttributeValue(w, kAXSizeAttribute as CFString, &sizeVal)
                var pos = CGPoint.zero
                var size = CGSize.zero
                if let pv = posVal as! AXValue?, AXValueGetValue(pv, .cgPoint, &pos),
                   let sv = sizeVal as! AXValue?, AXValueGetValue(sv, .cgSize, &size) {
                    let axBounds = CGRect(origin: pos, size: size)
                    if abs(axBounds.origin.x - bounds.origin.x) < 80 &&
                       abs(axBounds.origin.y - bounds.origin.y) < 80 &&
                       abs(axBounds.width - bounds.width) < 80 &&
                       abs(axBounds.height - bounds.height) < 80 {
                        matchedAXWindow = w
                        break
                    }
                }
            }

            // If matched AXWindow has subrole == AXUnknown, it is a helper/dummy window
            if let axWin = matchedAXWindow {
                var subVal: AnyObject?
                AXUIElementCopyAttributeValue(axWin, kAXSubroleAttribute as CFString, &subVal)
                if (subVal as? String) == "AXUnknown" {
                    return nil
                }
            } else {
                // If this window is a known Chromium utility window (<=600x600), skip it
                if (owner == "Arc" || owner == "Cursor" || owner == "Google Chrome") && bounds.width <= 600 && bounds.height <= 600 {
                    return nil
                }
            }
        } else if (owner == "Arc" || owner == "Cursor" || owner == "Google Chrome") && bounds.width <= 600 && bounds.height <= 600 {
            return nil
        }

        let target = AppTarget(pid: pid, appName: owner, bounds: bounds, windowElement: matchedAXWindow)
        return (target, bounds)
    }

    // 1. Priority 1: Window strictly containing mouseLoc (on current display)
    for info in list {
        if let (target, bounds) = checkWindowCandidate(info: info) {
            if bounds.contains(mouseLoc) {
                return (target, "under mouse")
            }
        }
    }

    // Interactive AX hit-test fallback for Priority 1 if trusted
    if isAXTrusted {
        let sys = AXUIElementCreateSystemWide()
        if let target = findAXWindow(sys: sys, point: mouseLoc) {
            if currentDisplay.contains(target.bounds.origin) || target.bounds.intersects(currentDisplay) {
                return (target, "under mouse")
            }
        }
    }

    // 2. Priority 2: Window covering center of current screen with cursor
    for info in list {
        if let (target, bounds) = checkWindowCandidate(info: info) {
            if bounds.contains(screenCenter) {
                return (target, "center of screen")
            }
        }
    }

    if isAXTrusted {
        let sys = AXUIElementCreateSystemWide()
        if let target = findAXWindow(sys: sys, point: screenCenter) {
            if currentDisplay.contains(target.bounds.origin) || target.bounds.intersects(currentDisplay) {
                return (target, "center of screen")
            }
        }
    }

    // 3. Priority 3: Frontmost visible window on this screen
    for info in list {
        if let (target, _) = checkWindowCandidate(info: info) {
            return (target, "frontmost on screen")
        }
    }

    return nil
}

// Activate application and raise specific window (without changing mouse position unless warp is explicitly requested)
@discardableResult
func focusWindow(target: AppTarget, warp: Bool = false, click: Bool = false) -> Bool {
    guard let app = NSRunningApplication(processIdentifier: target.pid) else {
        return false
    }

    let appElement = AXUIElementCreateApplication(target.pid)

    // 1. Resolve target AX window element
    var targetWindow = target.windowElement
    if targetWindow == nil {
        let windows = getAXWindows(appElement: appElement)
        var matchedWin: AXUIElement?
        var minDiff: CGFloat = .greatestFiniteMagnitude
        for win in windows {
            var subVal: AnyObject?
            AXUIElementCopyAttributeValue(win, kAXSubroleAttribute as CFString, &subVal)
            if (subVal as? String) == "AXUnknown" { continue }

            var posVal: AnyObject?
            var sizeVal: AnyObject?
            if AXUIElementCopyAttributeValue(win, kAXPositionAttribute as CFString, &posVal) == .success,
               AXUIElementCopyAttributeValue(win, kAXSizeAttribute as CFString, &sizeVal) == .success {
                var pos = CGPoint.zero
                var size = CGSize.zero
                if let pv = posVal as! AXValue?, AXValueGetValue(pv, .cgPoint, &pos),
                   let sv = sizeVal as! AXValue?, AXValueGetValue(sv, .cgSize, &size) {
                    let rect = CGRect(origin: pos, size: size)
                    let diff = abs(rect.origin.x - target.bounds.origin.x)
                             + abs(rect.origin.y - target.bounds.origin.y)
                             + abs(rect.width - target.bounds.width)
                             + abs(rect.height - target.bounds.height)
                    if diff < minDiff {
                        minDiff = diff
                        matchedWin = win
                    }
                }
            }
        }
        targetWindow = matchedWin
    }

    // 2. Multi-screen crucial step: Set main and raise the target window BEFORE activating the app!
    // This tells macOS which display & window to activate, preventing it from defaulting to other screens.
    if let win = targetWindow {
        AXUIElementSetAttributeValue(win, kAXMainAttribute as CFString, kCFBooleanTrue)
        AXUIElementPerformAction(win, kAXRaiseAction as CFString)
        AXUIElementSetAttributeValue(win, kAXFocusedAttribute as CFString, kCFBooleanTrue)
    }

    _ = AXUIElementSetAttributeValue(appElement, kAXFrontmostAttribute as CFString, kCFBooleanTrue)

    // 3. Direct NSWorkspace activation
    #if swift(>=5.9)
    if #available(macOS 14.0, *) {
        app.activate()
    } else {
        app.activate(options: [.activateIgnoringOtherApps])
    }
    #else
    app.activate(options: [.activateIgnoringOtherApps])
    #endif

    // Re-assert raise and main on the specific window after activation
    if let win = targetWindow {
        AXUIElementPerformAction(win, kAXRaiseAction as CFString)
        AXUIElementSetAttributeValue(win, kAXMainAttribute as CFString, kCFBooleanTrue)
    }

    // 4. Fallback activation via AppleScript if NSRunningApplication.activate() was suppressed by macOS background rules
    if !app.isActive {
        let scriptSource = "tell application \"System Events\" to set frontmost of (first process whose unix id is \(target.pid)) to true"
        if let appleScript = NSAppleScript(source: scriptSource) {
            var err: NSDictionary?
            appleScript.executeAndReturnError(&err)
        }
    }

    // 5. Optional synthetic click to guarantee key focus
    if click {
        let clickPoint = warp ? CGPoint(x: target.bounds.midX, y: target.bounds.midY) : (CGEvent(source: nil)?.location ?? CGPoint(x: target.bounds.midX, y: target.bounds.midY))
        postSyntheticClick(at: clickPoint)
    }

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
func startWatcher(delayMs: UInt32, warp: Bool, click: Bool) {
    setlinebuf(stdout)
    ensureAccessibilityPrompt()

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

            // Settling delay (default 80ms) to allow desktop slide animation to start
            if delayMs > 0 {
                usleep(delayMs * 1000)
            }

            // Retry loop (up to 6 attempts with 40ms intervals) to handle desktop switch animation settling
            var targetResult: (target: AppTarget, reason: String)?
            var mouseLoc = CGEvent(source: nil)?.location ?? .zero

            for attempt in 1...6 {
                mouseLoc = CGEvent(source: nil)?.location ?? .zero
                if let res = getTarget(mouseLoc: mouseLoc) {
                    targetResult = res
                    break
                }
                if attempt < 6 {
                    usleep(40_000)
                }
            }

            let timeStr = formatter.string(from: Date())

            if let target = targetResult {
                focusWindow(target: target.target, warp: warp, click: click)
                print("[\(timeStr)] Space changed -> Focused \(target.reason): \(target.target.appName) (PID: \(target.target.pid)) [mouse: (\(Int(mouseLoc.x)), \(Int(mouseLoc.y)))]")
                fflush(stdout)
            } else {
                print("[\(timeStr)] Space changed -> (No active application window) [mouse: (\(Int(mouseLoc.x)), \(Int(mouseLoc.y)))]")
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
var shouldClick = ProcessInfo.processInfo.environment["JUMP_DESKTOP_CLICK"] == "1"
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
    case "--click", "-c":
        shouldClick = true
    case "--no-click":
        shouldClick = false
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
    let delay = customDelayMs ?? 80
    startWatcher(delayMs: delay, warp: shouldWarp, click: shouldClick)
    exit(0)
}

guard let action = positionalArgs.first?.lowercased() else {
    printUsage()
    exit(0)
}

switch action {
case "focus":
    ensureAccessibilityPrompt()
    let mouseLoc = CGEvent(source: nil)?.location ?? .zero
    if let targetResult = getTarget(mouseLoc: mouseLoc) {
        focusWindow(target: targetResult.target, warp: shouldWarp, click: shouldClick)
        print("✓ Focused \(targetResult.reason): \(targetResult.target.appName) (PID: \(targetResult.target.pid)) [mouse: (\(Int(mouseLoc.x)), \(Int(mouseLoc.y)))]")
    } else {
        print("No visible window found to focus on current display [mouse: (\(Int(mouseLoc.x)), \(Int(mouseLoc.y)))].")
    }
case "service-run":
    // Internal command invoked by LaunchAgent: prints friendly message and runs watcher
    let delay = customDelayMs ?? 80
    startWatcher(delayMs: delay, warp: shouldWarp, click: shouldClick)
    exit(0)
default:
    fputs("Error: Invalid action '\(action)'. Use focus or --watch.\n", stderr)
    exit(1)
}

exit(0)
