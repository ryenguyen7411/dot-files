import AppKit
import Foundation

guard CommandLine.arguments.count > 1 else {
    fputs("Usage: imgcopy <image_path>\n", stderr)
    exit(1)
}

let path = CommandLine.arguments[1]
let fileURL = URL(fileURLWithPath: path)

guard let image = NSImage(contentsOf: fileURL) else {
    fputs("Error: Failed to load image from \(path)\n", stderr)
    exit(1)
}

let pasteboard = NSPasteboard.general
pasteboard.clearContents()
if pasteboard.writeObjects([image]) {
    exit(0)
} else {
    fputs("Error: Failed to write image to pasteboard\n", stderr)
    exit(1)
}
