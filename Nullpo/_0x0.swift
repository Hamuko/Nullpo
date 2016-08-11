import Foundation

class _0x0: UploaderProtocol {
    static let url = NSURL(string: "https://0x0.st")!
    static let data = [String: NSData]()
    static let errorMessages: [String] = [String]()
    
    static func daysValid(file: UploadFile) -> Int {
        let filesize: Double = Double(file.filesize) / 1024 / 1024
        let days: Double = 30.0 + (-365.0 + 30.0) * pow(filesize / 256.0 - 1.0, 3.0)
        return Int(days)
    }
}
