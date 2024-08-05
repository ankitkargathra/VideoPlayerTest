import Foundation

class VideoDownloader {
    
    static let shared = VideoDownloader()
    private var downloadTasks: [URL: URLSessionDataTask] = [:]
    private let fileManager = FileManager.default
    private var documentDirectory: URL {
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var downloadCompletion: ((URL?) -> ())?
    
    private init() {}
    
    // Check if the video is already cached
    func cachedVideoURL(for url: URL) -> URL? {
        let fileName = url.lastPathComponent
        let localURL = documentDirectory.appendingPathComponent(fileName)
        return fileManager.fileExists(atPath: localURL.path) ? localURL : nil
    }
    
    // Download the video and save it to the document directory
    func downloadVideo(from url: URL, completion: @escaping (URL?) -> Void) {
        if let cachedURL = cachedVideoURL(for: url) {
            // If cached, return the cached URL
            completion(cachedURL)
            return
        }
        
        let fileName = url.lastPathComponent
        let localURL = documentDirectory.appendingPathComponent(fileName)
        
        // Check if there's already an ongoing download for this URL
        if let downloadTask = downloadTasks[url], downloadTask.state == .running {
            // Download is in progress, ignore
            print("Download already in progress for \(url)")
            return
        }
        
        let urlSession = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let downloadTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Download failed: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                completion(nil)
                return
            }
            
            do {
                try data.write(to: localURL)
                print("Video saved to \(localURL.path)")
                completion(localURL)
                self.downloadCompletion?(localURL)
            } catch {
                print("Error saving video: \(error.localizedDescription)")
                completion(nil)
            }
            
            // Remove the task from tracking
            self.downloadTasks.removeValue(forKey: url)
        }
        
        
        // Track the download task
        downloadTasks[url] = downloadTask
        downloadTask.resume()
    }
    
    // Cancel the download if needed
    func cancelDownload(for url: URL) {
        if let downloadTask = downloadTasks[url] {
            downloadTask.cancel()
            downloadTasks.removeValue(forKey: url)
        }
    }
    
    func cancelAllDownloadTasks() {
        for (key, _) in downloadTasks {
            if let downloadTask = downloadTasks[key] {
                downloadTask.cancel()
            }
            
        }
        
    }
    
    
    func restartAllDownloadTasks() {
        for (key, _) in downloadTasks {
            if let downloadTask = downloadTasks[key] {
               downloadVideo(from: key, completion: {_ in})
            }
            print("Task \(key) restarted")
        }
    }
}
