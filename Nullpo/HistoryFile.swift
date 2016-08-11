import Foundation
import RealmSwift

class HistoryFile: RealmSwift.Object {
    dynamic var url: String = ""
    dynamic var date: NSDate = NSDate()
    dynamic var expires: NSDate?
    
    convenience init(file: UploadFile) {
        self.init()
        self.url = file.url!
        let calendar: NSCalendar = NSCalendar.currentCalendar()
        let dateComponents: NSDateComponents = NSDateComponents()
        dateComponents.day = file.daysValid!
        let expireDate: NSDate = calendar.dateByAddingComponents(dateComponents, toDate: date, options: NSCalendarOptions.MatchStrictly)!
        self.expires = expireDate
    }
}
