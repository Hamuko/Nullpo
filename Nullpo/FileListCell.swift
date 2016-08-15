import Cocoa

class FileListCell: NSTableCellView {
    @IBOutlet weak var fileURL: NSTextField!

    @IBAction func copyURL(sender: AnyObject) {
        Utility.copyURL(fileURL.stringValue)
    }

    func openURL() {
        Utility.openURL(fileURL.stringValue)
    }

    // TODO: Make setter.
    func setURL(string: String) {
        fileURL.cell?.stringValue = string
    }

}
