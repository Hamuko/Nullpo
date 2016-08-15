import Alamofire
import Cocoa
import RealmSwift

class UploadGroup {
    let files: [NSURL]
    let storage: FileListData
    let uploader: UploaderProtocol.Type
    let manager: Manager

    var uploadedFileCount: Int = 0
    var onCompletion: (Void -> Void)?
    var progressUpdater: ((Double) -> Void)? = nil

    static let uploaders: [String: UploaderProtocol.Type] = [
        "Uguu": Uguu.self,
        "0x0": _0x0.self
    ]

    init(files: [NSURL], fileStorage: FileListData) {
        self.files = files.sort { $0.lastPathComponent < $1.lastPathComponent }
        self.uploader = UploadGroup.preferredUploader()
        self.storage = fileStorage

        var concurrency = NSUserDefaults.standardUserDefaults().integerForKey("ConcurrentUploadJobs")
        if concurrency <= 0 {
            concurrency = 4
        }
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPMaximumConnectionsPerHost = concurrency
        self.manager = Manager(configuration: configuration)
    }

    /// Returns the number of uploads in group.
    var count: Int {
        return self.files.count
    }

    func onUploadCompletion(file: UploadFile) {
        uploadedFileCount += 1
        self.writeToDatabase(file)
        self.storage.addFile(file)
        if uploadedFileCount == files.count {
            onCompletion?()
        }
    }

    func onUploadFailure(file: UploadFile, message: String) {
        let center: NSUserNotificationCenter = NSUserNotificationCenter.defaultUserNotificationCenter()
        let notification: NSUserNotification = NSUserNotification()
        let filename: String = file.filePath.lastPathComponent!

        notification.title = "Upload failed"
        notification.informativeText = "Failed to upload \(filename): \(message)"
        center.deliverNotification(notification)
    }

    /// Returns the uploader set in the preferences file, or alternatively
    /// Uguu if no Uploader for the name can be found.
    /// - returns: UploaderProtocol.Type object to be used with the Uploader class.
    static func preferredUploader() -> UploaderProtocol.Type {
        let uploaderName: String =  NSUserDefaults.standardUserDefaults().objectForKey("Uploader") as? String ?? "Uguu"
        return UploadGroup.uploaders[uploaderName] ?? Uguu.self
    }

    func updateProgress(progress: Double) {
        guard let updater = self.progressUpdater else { return }
        updater(progress)
    }

    func upload() {
        let uploadQueue = NSOperationQueue()
        uploadQueue.maxConcurrentOperationCount = 1
        for (index, file) in self.files.enumerate() {
            let uploadFile = UploadFile(file: file, index: index)
            let task = UploadTask(file: uploadFile, group: self)
            uploadQueue.addOperation(task)
        }
        uploadQueue.waitUntilAllOperationsAreFinished()
    }

    func writeToDatabase(file: UploadFile) {
        let historyFile = HistoryFile(file: file)
        let realm = try! Realm()
        try! realm.write {
            realm.add(historyFile)
        }
    }

}

class UploadTask: NSOperation {
    let file: UploadFile
    let group: UploadGroup

    init(file: UploadFile, group: UploadGroup) {
        self.file = file
        self.group = group
    }

    override func main() {
        /// Append file and Uploader specific data to multipart form data.
        let formData: MultipartFormData -> Void = { multipartFormData in
            for (key, value) in self.group.uploader.data {
                multipartFormData.appendBodyPart(data: value, name: key)
            }
            multipartFormData.appendBodyPart(fileURL: self.file.filePath, name: "file")
        }

        /// Calculate additional progress per each write and return it to progressUploader closure.
        let progress: ((Int64, Int64, Int64) -> Void)? = { bytesWritten, _, totalBytesExpectedToWrite in
            let progress = Double(bytesWritten) / Double(totalBytesExpectedToWrite) / Double(self.group.count)
            self.group.progressUpdater?(progress)
        }

        /// Handle return from a successful POST request.
        let success: Response<String, NSError> -> Void = { response in
            guard let message = response.result.value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) else { return }
            if self.group.uploader.errorMessages.contains(message) {
                self.group.onUploadFailure(self.file, message: message)
            } else {
                self.file.daysValid = self.group.uploader.daysValid(self.file)
                self.file.url = message
                self.group.onUploadCompletion(self.file)
            }
        }

        group.manager.upload(.POST, self.group.uploader.url, multipartFormData: formData,
                             encodingCompletion: {encodingResult -> Void in
                                switch encodingResult {
                                case .Success(let upload, _, _):
                                    upload.progress(progress)
                                    upload.responseString(completionHandler: success)
                                case .Failure(let encodingError):
                                    print(encodingError)
                                }
        })
    }

}
