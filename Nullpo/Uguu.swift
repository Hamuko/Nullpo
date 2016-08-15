import Foundation

class Uguu: NSObject, UploaderProtocol {
    static let url = NSURL(string: "https://uguu.se/api.php?d=upload-tool")!
    static let data: [String: NSData] = ["randomname": "True".dataUsingEncoding(NSUTF8StringEncoding)!]
    static let errorMessages: [String] = ["File type not allowed."]

    static func daysValid(file: UploadFile) -> Int {
        return 1
    }

}
