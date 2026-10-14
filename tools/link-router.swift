import AppKit
import Foundation

// MARK: - Configuration Models

struct BrowserRule: Codable {
    let name: String
    let patterns: [String]          // Glob or Regex patterns (e.g. "*gitlab*", "*jira*", "youtube.com")
    let app: String                 // e.g. "Google Chrome", "Arc", "Brave Browser", "Safari"
    let profile: String?            // e.g. "Profile 1", "Work", "Default" (For Chrome/Brave/Edge)
    let incognito: Bool?
}

struct RouterConfig: Codable {
    let defaultApp: String
    let defaultProfile: String?
    let rules: [BrowserRule]
}

// MARK: - Core Link Router Logic

class LinkRouter {
    let config: RouterConfig

    init(config: RouterConfig) {
        self.config = config
    }

    static func defaultConfigFileURL() -> URL {
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        return homeDir.appendingPathComponent(".config/link-router/rules.json")
    }

    static func loadConfig() -> RouterConfig {
        let configFile = defaultConfigFileURL()
        if let data = try? Data(contentsOf: configFile),
           let loaded = try? JSONDecoder().decode(RouterConfig.self, from: data) {
            return loaded
        }

        // Default initial configuration
        return RouterConfig(
            defaultApp: "Arc",
            defaultProfile: nil,
            rules: [
                BrowserRule(
                    name: "Work / Internal Domains",
                    patterns: ["*gitlab*", "*github*", "*jira*", "*confluence*", "*figma*", "*slack*", "*aws*"],
                    app: "Google Chrome",
                    profile: "Work",
                    incognito: false
                ),
                BrowserRule(
                    name: "Entertainment & Personal",
                    patterns: ["*youtube.com*", "*youtu.be*", "*reddit.com*", "*facebook.com*", "*twitter.com*", "*x.com*"],
                    app: "Arc",
                    profile: nil,
                    incognito: false
                )
            ]
        )
    }

    static func saveDefaultConfigIfMissing() {
        let configFile = defaultConfigFileURL()
        let folder = configFile.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)

        if !FileManager.default.fileExists(atPath: configFile.path) {
            let initial = loadConfig()
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            if let data = try? encoder.encode(initial) {
                try? data.write(to: configFile)
            }
        }
    }

    func matchRule(for urlString: String) -> BrowserRule? {
        let lowerURL = urlString.lowercased()

        for rule in config.rules {
            for pattern in rule.patterns {
                let lowerPattern = pattern.lowercased()
                if lowerPattern.contains("*") {
                    let regexPattern = "^" + NSRegularExpression.escapedPattern(for: lowerPattern)
                        .replacingOccurrences(of: "\\*", with: ".*") + "$"
                    if let regex = try? NSRegularExpression(pattern: regexPattern, options: .caseInsensitive),
                       regex.firstMatch(in: lowerURL, options: [], range: NSRange(location: 0, length: lowerURL.utf16.count)) != nil {
                        return rule
                    }
                } else if lowerURL.contains(lowerPattern) {
                    return rule
                }
            }
        }
        return nil
    }

    func open(urlString: String) {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Clean link automatically before opening
        let cleanedURL = trimmed

        let matchedRule = matchRule(for: cleanedURL)
        let targetApp = matchedRule?.app ?? config.defaultApp
        let targetProfile = matchedRule?.profile ?? config.defaultProfile
        let isIncognito = matchedRule?.incognito ?? false

        print("\u{001B}[32mRouting to:\u{001B}[0m \(targetApp)\(targetProfile != nil ? " [Profile: \(targetProfile!)]" : "")")

        // Build CLI command for profiles (Chrome/Chromium based browsers support --profile-directory)
        if let profile = targetProfile, targetApp.contains("Chrome") || targetApp.contains("Brave") || targetApp.contains("Edge") {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            var args = ["-na", targetApp, "--args", "--profile-directory=\(profile)"]
            if isIncognito {
                args.append("--incognito")
            }
            args.append(cleanedURL)
            process.arguments = args
            try? process.run()
        } else {
            // Standard macOS Open
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
            var args = ["-a", targetApp]
            if isIncognito && (targetApp.contains("Chrome") || targetApp.contains("Brave")) {
                args.append(contentsOf: ["--args", "--incognito"])
            }
            args.append(cleanedURL)
            process.arguments = args
            try? process.run()
        }
    }
}

// MARK: - CLI Interface

func printUsage() {
    print("""
    \u{001B}[1mlink-router\u{001B}[0m - Smart Cross-Browser & Multi-Profile URL Router

    \u{001B}[1mUsage:\u{001B}[0m
      link-router <url>              Open URL with smart matched browser/profile
      link-router                    Open URL currently in clipboard
      link-router config             Show or edit rules configuration (~/.config/link-router/rules.json)
      link-router -h, --help         Show this help message

    \u{001B}[1mConfig Location:\u{001B}[0m
      ~/.config/link-router/rules.json
    """)
}

let args = CommandLine.arguments

LinkRouter.saveDefaultConfigIfMissing()
let router = LinkRouter(config: LinkRouter.loadConfig())

if args.contains("-h") || args.contains("--help") {
    printUsage()
    exit(0)
}

if args.count > 1 && args[1] == "config" {
    let path = LinkRouter.defaultConfigFileURL().path
    print("Opening config: \(path)")
    let editor = ProcessInfo.processInfo.environment["EDITOR"] ?? "nvim"
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = [editor, path]
    try? process.run()
    process.waitUntilExit()
    exit(0)
}

var urlToOpen: String?

if args.count > 1 {
    urlToOpen = args[1]
} else {
    // Read from clipboard
    if let clip = NSPasteboard.general.string(forType: .string),
       clip.starts(with: "http://") || clip.starts(with: "https://") {
        urlToOpen = clip
    }
}

guard let target = urlToOpen else {
    fputs("No valid HTTP/HTTPS URL found in arguments or clipboard.\n", stderr)
    exit(1)
}

router.open(urlString: target)
