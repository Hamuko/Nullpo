import Cocoa

class HistoryController: NSWindowController {
    @IBOutlet weak var historyTable: NSTableView!
    @IBOutlet weak var historyData: HistoryData!

    convenience init() {
        self.init(windowNibName: "HistoryController")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        historyTable.doubleAction = #selector(HistoryController.tableDoubleClicked(_:))
        historyTable.target = self
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        historyData.refresh()
        resizeColumns()
    }
    
    @IBAction func menuCopy(sender: AnyObject) {
        guard let row: Int = historyTable.clickedRow where row > -1 else {
            return
        }
        Utility.copyURL(URLForRow(row))
    }

    @IBAction func menuOpen(sender: AnyObject) {
        guard let row: Int = historyTable.clickedRow where row > -1 else {
            return
        }
        Utility.openURL(URLForRow(row))
    }
    
    /// Resizes both of the date columns to fit their content and then resizes the first column
    /// to take all the remaining space without stretching the NSTableView over the window bounds.
    func resizeColumns() {
        let columnCount: Int = historyTable.numberOfColumns
        let rowCount: Int = historyTable.numberOfRows
    
        for columnIndex in 1..<columnCount {
            let column = historyTable.tableColumns[columnIndex]

            for rowIndex in 0..<rowCount {
                let cell: NSCell = historyTable.preparedCellAtColumn(columnIndex, row: rowIndex)!
                let width: CGFloat = cell.cellSize.width

                if column.width < width {
                    column.minWidth = width + 2
                    column.width = width + 2
                }
            }
        }
        
        let overflowWidth: CGFloat = historyTable.frame.width - historyTable.visibleRect.width
        historyTable.tableColumns[0].width -= overflowWidth
    }
    
    func tableDoubleClicked(sender: AnyObject) {
        guard let row: Int = historyTable.clickedRow where row > -1 else {
            // Invalid row has been double-clicked.
            return
        }
        Utility.openURL(URLForRow(row))
    }
    
    func URLForRow(row: Int) -> NSURL {
        let cellString: String = historyTable.preparedCellAtColumn(0, row: row)!.stringValue
        return NSURL(string: cellString)!
    }
}
