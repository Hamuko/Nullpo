import Cocoa

/// Class used to draw the dragging indicator image into the DraggingZone view without the use of NSImage.
class DraggingIndicator: NSView {
    override func drawRect(dirtyRect: NSRect) {
        let image: NSImage = NSImage(named: "DragIndicator")!
        image.drawInRect(dirtyRect)
    }
}
