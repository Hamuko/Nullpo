import Cocoa

class FileListData : NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var fileTable: NSTableView!
    
    var fileList = [UploadFile]()
    
    /// Pushes a new URL onto the file list.
    /// - parameter file: File URL string.
    func addFile(file: UploadFile) {
        fileList.append(file)
        fileTable.reloadData()
    }
    
    /// Clear the entire file list.
    func clearFiles() {
        fileList = [UploadFile]()
        fileTable.reloadData()
    }
    
    var count: Int {
        return fileList.count;
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return fileList.count;
    }
    
    func remove(index: Int) {
        fileList.removeAtIndex(index)
        fileTable.reloadData()
    }
    
    func sort(numberOfItems: Int) {
        let sortRange: Range<Int> = fileList.count - numberOfItems...fileList.count - 1
        let sorted = fileList[sortRange].sort({ $0.index < $1.index })
        fileList.replaceRange(sortRange, with: sorted)
        fileTable.reloadData()
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: FileListCell = tableView.makeViewWithIdentifier(tableColumn!.identifier, owner: self) as! FileListCell
        cell.fileURL.stringValue = fileList[row].url!
        return cell;
    }
}
