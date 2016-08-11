import Cocoa
import RealmSwift

class HistoryData : NSObject, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var historyTable: NSTableView!
    @IBOutlet weak var historyWindow: NSWindow!
    @IBOutlet weak var itemCount: NSTextField!
    @IBOutlet weak var progressSpinner: NSProgressIndicator!
    var historyData: Results<HistoryFile>?
    var historyDataTotalCount: Int
    
    override init() {
        self.historyDataTotalCount = 0
        super.init()
    }
    
    var count: Int {
        return historyData?.count ?? 0
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return count
    }
    
    func refresh() {
        progressSpinner.hidden = false
        self.queryHistoryData()
        historyTable.reloadData()
        if historyDataTotalCount - count > 0 {
            itemCount.stringValue = "\(count) items (\(historyDataTotalCount - count) hidden)"
        } else {
            itemCount.stringValue = "\(count) items"
        }
        progressSpinner.hidden = true
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        guard let header: String = tableColumn?.headerCell.stringValue else { return nil }
        guard let file: HistoryFile = historyData![row] else { return nil }
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .NoStyle
        
        switch header {
            case "URL": return file.url
            case "Added": return dateFormatter.stringFromDate(file.date)
            case "Expires": return dateFormatter.stringFromDate(file.expires!)
            default: return nil
        }
    }
    
    func queryHistoryData() {
        let realm = try! Realm()
        let predicate = NSPredicate(format: "expires > %@", NSDate())
        historyDataTotalCount = realm.objects(HistoryFile).count
        historyData = realm.objects(HistoryFile).filter(predicate).sorted("date", ascending: false)
    }
}
