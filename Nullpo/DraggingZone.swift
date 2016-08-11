import Cocoa

/// NSView subclass that implements the drag-and-drop methods used by Nurupo.
class DraggingZone : NSView {
    @IBOutlet weak var dragIndicator: DraggingIndicator!
    @IBOutlet var nullpoController: NullpoController!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.registerForDraggedTypes([NSURLPboardType])
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        dragIndicator.animator().hidden = false
        
        return NSDragOperation.Every
    }
    
    override func draggingExited(sender: NSDraggingInfo?) {
        dragIndicator.animator().hidden = true
    }
    
    override func draggingUpdated(sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.Every
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        dragIndicator.animator().hidden = true
        
        let pasteboard: NSPasteboard = sender.draggingPasteboard()
        let files = pasteboard.readObjectsForClasses([NSURL.self], options: nil)
        
        nullpoController.upload(files as! [NSURL])
        
        return true
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        return true
    }
}
