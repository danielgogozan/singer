//
//  DownloadSongOperation.swift
//  Singer
//
//  Created by Daniel Gogozan on 09.11.2021.
//

import Foundation


// This operation literally downloads the audio data for a specific song
final class PreviewDownloadOperation: AsyncOperation {
    
    private lazy var urlSession : URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }()
    
    private var downloadTask: URLSessionDownloadTask?
    
    var song: Song?
    
    private var downloadUrl: URL?
    
    var savePreviewCompletion: ((URL) -> Void)

    init(savePreviewCompletion: @escaping (URL) -> Void) {
        self.savePreviewCompletion = savePreviewCompletion
        super.init()
    }
    
    override func main() {
        // 1. get the song metadata
        print("[PreviewDownloadOperation] dependencies: \(dependencies)")
        
        // comment this if using adapther method
//        song = dependencies
//            .compactMap { ($0 as? SongDataProvider)?.song }
//            .first
        
        guard let song = self.song else {
            return
        }
        
        // 2. download the mp4
        guard let url = URL(string: song.preview) else {
            return
        }
        downloadUrl = url
        downloadTask = urlSession.downloadTask(with: url)
        downloadTask?.resume()
    }
    
    override func cancel() {
        super.cancel()
        downloadTask?.cancel()
    }
}

extension PreviewDownloadOperation: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        defer {state = .finished}
        
        let fileManager = FileManager.default
        guard let docPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let fileName = downloadUrl?.lastPathComponent else {
                  return
              }
        
        let destinationUrl = docPath.appendingPathComponent(fileName)
        
        do{
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try fileManager.removeItem(at: destinationUrl)
            }
            try fileManager.copyItem(at: location, to: destinationUrl)
            self.savePreviewCompletion(destinationUrl)
        } catch {
            print("ERROR >>> \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print("Something went wrong while downloading: \(error.localizedDescription)")
        }
    }
}
