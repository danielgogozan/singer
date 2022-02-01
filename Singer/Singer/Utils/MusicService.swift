//
//  MusicApi.swift
//  Singer
//
//  Created by Daniel Gogozan on 07.11.2021.
//

import UIKit

enum NetworkError: Error {
    case invalidURL
    case decodingError
    case internalFiles
    case wsError
}

enum DownloadState {
    case none
    case downloading
    case paused
    case finished
}

class MusicService: NSObject {
    
    private let baseUrl = "https://itunes.apple.com/search?media=music&entity=song&term="
    
    var downloads = [Int: MetaDataDownload]()
    
    // create init for session & filemanager
    private var urlSession: URLSession
    
    private var fileManager: FileManager
    
    init(urlSessionConfiguration: URLSessionConfiguration, fileManager: FileManager) {
        self.fileManager = fileManager
        self.urlSession = URLSession()
        super.init()
        self.urlSession = URLSession(configuration: urlSessionConfiguration, delegate: self, delegateQueue: nil)
    }
    
    private var downloadCompletion: ((Result<URL, NetworkError>) -> Void)?
    
    func getMusic(query: String, completion: @escaping (Result<[Song], NetworkError>) -> Void) {
        print("getting music...")
        var music: Music = Music(results: [])
        
        guard let url = URL(string: baseUrl + query) else {
            completion(.failure(.invalidURL))
            return
        }
        
        urlSession.dataTask(with: url) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                      fatalError("Error with status code")
                  }
            guard let data = data else {
                return
            }
            do {
                music = try JSONDecoder().decode(Music.self, from: data)
                completion(.success(music.results))
            } catch {
                print("JSONDecoder error: \(error)")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func getDownloadDestination(for songId: Int) -> URL? {
        if let destinationUrl = downloads[songId]?.destinationUrl {
            return destinationUrl
        }
        return nil
    }
    
    func checkIfDownloadExists(songId: Int) -> Bool {
        if let _ = getDownloadDestination(for: songId) {
            return true
        }
        
        if let resumedData = downloads[songId]?.resumedData {
            downloads[songId]?.downloadTask = urlSession.downloadTask(withResumeData: resumedData)
            downloads[songId]?.downloadTask.resume()
        }
        
        return false
    }
    
    func download(songId: Int, preview: String, progress: @escaping (Float) -> Void, completion: @escaping (URL) -> Void) -> Int? {
        print(checkIfDownloadExists(songId: songId))
        print(downloads.count)
        // extra check
        if checkIfDownloadExists(songId: songId) {
            return nil
        }
        
        guard let url = URL(string: preview) else {
            return nil
        }
        let downloadTask = urlSession.downloadTask(with: url)
        downloads[songId] = MetaDataDownload(downloadTask: downloadTask, sourceUrl: url, destinationUrl: nil, progress: progress, completion: completion, resumedData: nil)
        downloadTask.resume()
        return downloadTask.taskIdentifier
    }
    
    func pauseDownload(with id: Int) {
        downloads[id]?.downloadTask.cancel(byProducingResumeData: { [weak self] data in
            self?.downloads[id]?.resumedData = data
        })
    }
    
    func resumeDownload(with id: Int) {
        guard let resumedData = downloads[id]?.resumedData else {
            return
        }
        downloads[id]?.downloadTask = urlSession.downloadTask(withResumeData: resumedData)
        downloads[id]?.downloadTask.resume()
    }
    
    func cancelDownload(with id: Int) {
        downloads[id]?.downloadTask.cancel()
        downloads[id] = nil
    }
    
    private func getSongIdByDownloadTaskIdentifier(taskIdentifier: Int) -> Int? {
        downloads.first(where: { key, value in
            value.downloadTask.taskIdentifier == taskIdentifier
        })?.key
    }
}

extension MusicService: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 1. setup doc path and fileName
        
        guard   let songId = getSongIdByDownloadTaskIdentifier(taskIdentifier: downloadTask.taskIdentifier),
                let metadata = downloads[songId],
                let docPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        else {
            return
        }
        
        // 2. add fileName to the path component and set it as destination
        let destinationUrl = docPath.appendingPathComponent(metadata.sourceUrl.lastPathComponent)
        
        // 3. copy item to destination
        do {
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try fileManager.removeItem(at: destinationUrl)
            }
            try fileManager.copyItem(at: location, to: destinationUrl)
            metadata.completion(destinationUrl)
            downloads[songId]?.destinationUrl = destinationUrl
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let songId = getSongIdByDownloadTaskIdentifier(taskIdentifier: downloadTask.taskIdentifier) else {
            return
        }
        downloads[songId]?.progress(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            print(error)
        }
    }
}
