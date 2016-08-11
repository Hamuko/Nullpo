import Cocoa

class Utility {
    /// Copies the given NSURL to clipboard.
    static func copyURL(url: NSURL) {
        copyURL(url.absoluteString)
    }
    
    /// Copies the given String to clipboard.
    static func copyURL(text: String) {
        let pasteboard: NSPasteboard = NSPasteboard.generalPasteboard()
        pasteboard.declareTypes([NSStringPboardType], owner: self)
        pasteboard.setString(text, forType: NSPasteboardTypeString)
    }
    
    /// Open an NSURL object with the default application.
    static func openURL(URL: NSURL) {
        let background: Bool = NSUserDefaults.standardUserDefaults().boolForKey("OpenLinksInBackground")
        let workspace: NSWorkspace = NSWorkspace.sharedWorkspace()
        
        if background {
            workspace.openURLs([URL], withAppBundleIdentifier: nil, options: .WithoutActivation, additionalEventParamDescriptor: nil, launchIdentifiers: nil)
        } else {
            workspace.openURL(URL)
        }
    }
    
    /// Open a given string as an URL with the default application.
    static func openURL(URLString: String) {
        guard let url: NSURL = NSURL(string: URLString)! else { return }
        openURL(url)
    }
}
