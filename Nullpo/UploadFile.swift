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

    /// Filesize in bytes. Returns 0 in case of error.
    var filesize: Int {
        guard let resourceValues: [String: AnyObject] = try? self.filePath.resourceValuesForKeys([NSURLFileSizeKey]) else { return 0 }
        if let filesize = resourceValues[NSURLFileSizeKey] as? Int {
            return filesize
        } else {
            return 0
        }
    }
}
