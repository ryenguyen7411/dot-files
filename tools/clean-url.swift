import AppKit
import Foundation

// MARK: - Tracker Stripper Engine

struct URLCleaner {
    // Standard tracking and analytics query parameter keys
    static let trackingParameters: Set<String> = [
        // Google Analytics / Ads
        "utm_source", "utm_medium", "utm_campaign", "utm_term", "utm_content", "utm_id",
        "gclid", "gclsrc", "dclid", "wbraid", "gbraid", "_ga", "_gl",

        // Facebook / Instagram / Meta
        "fbclid", "igshid", "fb_action_ids", "fb_action_types", "fb_source", "fb_ref",

        // YouTube / Google
        "si", "feature", "pp",

        // Twitter / X
        "s", "t", "ref_src", "ref_url", "twclid",

        // TikTok / ByteDance
        "tt_medium", "tt_content", "share_item_id", "share_link_id", "is_copy_url",

        // Amazon / E-Commerce
        "tag", "linkCode", "creativeASIN", "ascsubtag", "ref_", "_encoding", "pd_rd_w", "pd_rd_r", "pd_rd_wg", "pf_rd_r", "pf_rd_p",

        // Shopee / Lazada / Tiki
        "sp_atk", "xptdk", "aff_trace_key",

        // General / Affiliate / Tracking
        "ref", "referer", "referrer", "origin", "source", "affiliate_id", "aff_id",
        "mc_cid", "mc_eid", "vero_id", "vero_conv", "_hsenc", "_hsmi", "mkt_tok",
        "yclid", "zanpid", "msclkid"
    ]

    static func clean(urlString: String) -> String {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return urlString
        }

        // Special handling for YouTube shortened / tracking URLs
        if let host = components.host?.lowercased() {
            if host.contains("youtu.be") || host.contains("youtube.com") {
                // Keep 'v' (video id) and 't' (timestamp if numeric)
                if let queryItems = components.queryItems {
                    let filtered = queryItems.filter { item in
                        let name = item.name.lowercased()
                        if name == "v" { return true }
                        if name == "t" || name == "time_continue" {
                            // keep timestamp
                            return true
                        }
                        if name == "list" || name == "index" {
                            // keep playlist
                            return true
                        }
                        return !trackingParameters.contains(name)
                    }
                    components.queryItems = filtered.isEmpty ? nil : filtered
                }
            } else if let queryItems = components.queryItems {
                let filtered = queryItems.filter { item in
                    let name = item.name.lowercased()
                    if trackingParameters.contains(name) { return false }
                    if name.starts(with: "utm_") { return false }
                    return true
                }
                components.queryItems = filtered.isEmpty ? nil : filtered
            }
        }

        return components.url?.absoluteString ?? urlString
    }

    static func extractAndCleanURLs(in text: String) -> (cleanedText: String, cleanCount: Int) {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return (text, 0)
        }

        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        guard !matches.isEmpty else {
            return (text, 0)
        }

        var result = text
        var modifiedCount = 0

        // Iterate backwards so ranges remain valid
        for match in matches.reversed() {
            guard let range = Range(match.range, in: result) else { continue }
            let rawUrl = String(result[range])
            let cleaned = clean(urlString: rawUrl)
            if cleaned != rawUrl {
                result.replaceSubrange(range, with: cleaned)
                modifiedCount += 1
            }
        }

        return (result, modifiedCount)
    }
}

// MARK: - CLI & Watcher Mode

func printUsage() {
    print("""
    \u{001B}[1mclean-url\u{001B}[0m - Instant Tracker Stripper & URL Cleaner for macOS

    \u{001B}[1mUsage:\u{001B}[0m
      clean-url [url_or_text]        Clean input string or clean current clipboard text
      clean-url --watch              Run lightweight background watcher on clipboard (auto-cleans on copy)
      clean-url -h, --help           Show this help message

    \u{001B}[1mExamples:\u{001B}[0m
      clean-url "https://youtu.be/xyz?si=track123&utm_source=share"
      clean-url                      # Cleans current clipboard content in-place
    """)
}

let args = CommandLine.arguments

if args.contains("-h") || args.contains("--help") {
    printUsage()
    exit(0)
}

if args.contains("--watch") {
    print("\u{001B}[32m✓ clean-url watcher active. Monitoring clipboard for tracking links...\u{001B}[0m")
    let pasteboard = NSPasteboard.general
    var lastChangeCount = pasteboard.changeCount

    while true {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            if let text = pasteboard.string(forType: .string) {
                let (cleaned, count) = URLCleaner.extractAndCleanURLs(in: text)
                if count > 0 && cleaned != text {
                    pasteboard.clearContents()
                    pasteboard.setString(cleaned, forType: .string)
                    lastChangeCount = pasteboard.changeCount
                    print("\u{001B}[36m[Cleaned \(count) link(s)]\u{001B}[0m \(cleaned.prefix(80))...")
                }
            }
        }
        usleep(250_000) // Poll every 250ms (ultra-lightweight, 0% CPU)
    }
} else if args.count > 1 {
    let input = args.dropFirst().joined(separator: " ")
    let (cleaned, _) = URLCleaner.extractAndCleanURLs(in: input)
    print(cleaned)
} else {
    // Process current clipboard
    let pasteboard = NSPasteboard.general
    guard let text = pasteboard.string(forType: .string) else {
        fputs("Clipboard is empty or contains non-text data.\n", stderr)
        exit(0)
    }

    let (cleaned, count) = URLCleaner.extractAndCleanURLs(in: text)
    if count > 0 {
        pasteboard.clearContents()
        pasteboard.setString(cleaned, forType: .string)
        print("✓ Cleaned \(count) link(s) in clipboard:\n\(cleaned)")
    } else {
        print("No tracking parameters found in clipboard content.")
    }
}
