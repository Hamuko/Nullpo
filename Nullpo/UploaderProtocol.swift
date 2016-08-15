import Foundation

protocol UploaderProtocol {
    static var url: NSURL { get }
    static var data: [String: NSData] { get }
    static var errorMessages: [String] { get }

    static func daysValid(file: UploadFile) -> Int
}
