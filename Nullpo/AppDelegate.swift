import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    let nullpoController = NullpoController()
    var historyController: HistoryController?
    var preferenceController: PreferenceController?
    
    /// Upload files that are dragged to the application bundle.
    func application(sender: NSApplication, openFiles: [String]) {
        nullpoController.showWindow(nil)
        var files: [NSURL] = [NSURL]()
        for path in openFiles {
            files.append(NSURL(fileURLWithPath: path))
        }
        nullpoController.upload(files)
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        nullpoController.showWindow(nil)
    }
    
    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        sender.windows.first?.makeKeyAndOrderFront(sender)
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {}

    func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
    
    func openHistoryWindow(sender: AnyObject) {
        if historyController == nil {
            historyController = HistoryController()
        }
        historyController?.showWindow(nil)
    }
    
    func openPreferenceWindow(sender: AnyObject) {
        if preferenceController == nil {
            preferenceController = PreferenceController()
        }
        preferenceController?.showWindow(nil)
    }
    
    func openMainWindow(sender: AnyObject) {
        nullpoController.showWindow(nil)
    }
}
