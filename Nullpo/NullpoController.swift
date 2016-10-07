import Cocoa

class NullpoController: NSWindowController {
    @IBOutlet var fileStorage: FileListData!
    @IBOutlet weak var fileTable: NSTableView!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var bottomBarText: NSTextField!
    var controlsLocked = false

    convenience init() {
        self.init(windowNibName: "NullpoController")
    }

    override func windowDidLoad() {
        super.windowDidLoad()
        let doubleClickSelector: Selector = #selector(HistoryController.tableDoubleClicked(_:))
        fileTable.doubleAction = doubleClickSelector
        fileTable.target = self
    }

    /// Clears one or more selected URLs.
    func clear(sender: AnyObject) {
        for index in fileTable.selectedRowIndexes.reverse() {
            fileStorage.remove(index)
        }
        self.updateBottomBarText()
    }

    /// Clears all the URLs in window.
    func clearAll(sender: AnyObject) {
        self.fileStorage.clearFiles()
        self.updateBottomBarText()
    }

    /// Copies one or more selected URLs.
    func copy(sender: AnyObject) {
        var copyString: String = ""
        for index in fileTable.selectedRowIndexes {
            copyString += fileStorage.fileList[index].url!
            copyString += "\n"
        }
        Utility.copyURL(copyString)
    }

    /// Returns a boolean value indicating whether a row is selected or not.
    func isRowSelected() -> Bool {
        if fileTable.selectedRow > -1 {
            return true
        } else {
            return false
        }
    }

    /// Opens one or more selected URLs in the default application.
    func openDocument(sender: AnyObject) {
        for index in fileTable.selectedRowIndexes {
            Utility.openURL(fileStorage.fileList[index].url!)
        }
    }

    func saveDocumentAs(sender: AnyObject) {
        let fileDialog = NSSavePanel()
        fileDialog.allowedFileTypes = ["txt"]
        fileDialog.nameFieldStringValue = "nullpo"
        fileDialog.canSelectHiddenExtension = true
        fileDialog.extensionHidden = false
        fileDialog.beginSheetModalForWindow(self.window!, completionHandler: {button -> Void in
            if button == NSFileHandlingPanelOKButton {
                let path: NSURL = fileDialog.URL!
                let urls: String = self.fileStorage.fileList.map { $0.url! }.joinWithSeparator("\n") + "\n"
                do {
                    try urls.writeToURL(path, atomically: true, encoding: NSUTF8StringEncoding)
                } catch {
                    let error = error as NSError
                    let notification: NSUserNotification = NSUserNotification()
                    notification.title = "Write failed"
                    notification.informativeText = error.localizedDescription
                }
            }
        })
    }

    func tableDoubleClicked(sender: AnyObject) {
        guard let row: Int = fileTable.clickedRow where row > -1 else {
            // Invalid row has been double-clicked.
            return
        }
        let cell: FileListCell = fileTable.viewAtColumn(0, row: row, makeIfNecessary: false) as! FileListCell
        cell.openURL()
    }

    func updateProgressBar(progress: Double) {
        NSAnimationContext.beginGrouping()
        NSAnimationContext.currentContext().duration = 0.5
        self.progressBar.doubleValue += progress * 100.0
        if self.progressBar.doubleValue >= 99.90 {
            self.progressBar.hidden = true
            self.bottomBarText.hidden = false
        } else {
            self.progressBar.hidden = false
            self.bottomBarText.hidden = true
        }
        self.progressBar.displayIfNeeded()
        NSAnimationContext.endGrouping()
    }

    /// Updates the bottom bar text label's text and visibility.
    func updateBottomBarText() {
        if fileStorage.count == 1 {
            bottomBarText.stringValue = "\(fileStorage.count) item"
        } else {
            bottomBarText.stringValue = "\(fileStorage.count) items"
        }
        if fileStorage.count > 0 {
            bottomBarText.hidden = false
        } else {
            bottomBarText.hidden = true
        }
    }

    func upload(files: [NSURL]) {
        controlsLocked = true

        let uploader = UploadGroup(files: files, fileStorage: self.fileStorage)
        uploader.progressUpdater = { progress in
            self.updateProgressBar(progress)
        }
        uploader.onCompletion = {
            self.progressBar.doubleValue = 0
            self.progressBar.hidden = true
            self.updateBottomBarText()
            self.fileStorage.sort(uploader.uploadedFileCount)
            self.uploadCompletedNotification(uploader.uploadedFileCount)
            self.controlsLocked = false
        }
        uploader.upload()
    }

    func uploadCompletedNotification(uploadedFileCount: Int) {
        let center: NSUserNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        let notification: NSUserNotification = NSUserNotification()

        notification.title = "Upload completed"
        if uploadedFileCount == 1 {
            notification.informativeText = self.fileStorage.fileList.last!.url
        } else {
            notification.informativeText = "Finished uploading \(uploadedFileCount) files"
        }
        center.deliverNotification(notification)
    }

    /// Opens a file dialog that accepts multiple files at once and uploads them.
    func uploadDialog(sender: AnyObject) {
        let fileDialog = NSOpenPanel()
        fileDialog.allowsMultipleSelection = true
        fileDialog.runModal()
        upload(fileDialog.URLs)
    }

    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        let action = menuItem.action
        switch action {
        case #selector(NullpoController.clear(_:)):
            return isRowSelected() && !controlsLocked
        case #selector(NullpoController.copy(_:)):
            return isRowSelected() && !controlsLocked
        case #selector(NullpoController.openDocument(_:)):
            return isRowSelected() && !controlsLocked
        default:
            return true
        }
    }

}
