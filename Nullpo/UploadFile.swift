import Foundation

class UploadFile {
    let filePath: NSURL
    let index: Int
    var url: String?
    var daysValid: Int?
    
    init(file: NSURL, index: Int) {
        self.filePath = file
        self.index = index
    }
    
    /// Filesize in bytes.
    var filesize: Int {
        let filesize: Int = try! self.filePath.resourceValuesForKeys([NSURLFileSizeKey])[NSURLFileSizeKey] as! Int
        return filesize
    }
}
