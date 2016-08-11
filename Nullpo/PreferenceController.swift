import Cocoa

class PreferenceController: NSWindowController {
    @IBOutlet weak var backgroundLinkCheckbox: NSButton!
    @IBOutlet weak var uploaderList: NSPopUpButton!
    @IBOutlet weak var concurrentStepper: NSStepper!
    dynamic var concurrentUploadCount = 4
    
    
    convenience init() {
        self.init(windowNibName: "PreferenceController")
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        populateUploaderList()
        loadUserPreferences()
    }
    
    /// Opening links in background was changed via the checkbox.
    @IBAction func changedBackgroundLinks(sender: AnyObject) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let openLinksInBackground: Bool = Bool(backgroundLinkCheckbox.state)
        defaults.setBool(openLinksInBackground, forKey: "OpenLinksInBackground")
    }
    
    @IBAction func changedConcurrentUploadCount(sender: AnyObject) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        defaults.setInteger(sender.integerValue, forKey: "ConcurrentUploadJobs")
    }
    
    /// Uploader was changed using the pop-up button.
    @IBAction func changedUploader(sender: AnyObject) {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let selectedUploader: String = uploaderList.selectedItem!.title
        defaults.setObject(selectedUploader, forKey: "Uploader")
    }
    
    /// Populate the settings window with NSUserDefaults values.
    func loadUserPreferences() {
        let defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        var concurrentUploads: Int = defaults.integerForKey("ConcurrentUploadJobs")
        let openLinksInBackground: Bool = defaults.boolForKey("OpenLinksInBackground")
        let uploaderName: String = defaults.objectForKey("Uploader") as? String ?? "Uguu"
        
        if concurrentUploads <= 0 || concurrentUploads > 64 {
            concurrentUploads = 1
        }
        
        backgroundLinkCheckbox.state = Int(openLinksInBackground)
        concurrentUploadCount = concurrentUploads
        uploaderList.selectItem(uploaderList.itemWithTitle(uploaderName))
    }
    
    /// Add keys from Uploaders.plist to the pop-up button.
    func populateUploaderList() {
        uploaderList.addItemsWithTitles(Array(UploadGroup.uploaders.keys))
    }
}
