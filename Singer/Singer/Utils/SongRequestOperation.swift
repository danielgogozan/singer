//
//  GetSongOperation.swift
//  Singer
//
//  Created by Daniel Gogozan on 09.11.2021.
//

import Foundation

// This operation makes a request to the server in order to get the song
final class SongRequestOperation: AsyncOperation {

    private var task: URLSessionDataTask?
    
    private lazy var urlSession: URLSession = {
        return URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }()
    
    var song: Song?

    override func main() {
        guard let url = URL(string: "http://localhost:8080/song") else {
            return
        }
        
        task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            defer { self?.state = .finished }
            
            guard let httpResponse  = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                      fatalError("Bad http response")
                  }
            guard let data = data else {
                fatalError()
            }
            do {
                self?.song = try JSONDecoder().decode(Song.self, from: data)
                print("[SongRequestOperation] RECEIVED: \(self?.song)")
            } catch {
                print("Decoding error \(error)")
            }
        }
        task?.resume()
    }
    
    override func cancel() {
      super.cancel()
      task?.cancel()
    }
}

extension SongRequestOperation: URLSessionDelegate{}

extension SongRequestOperation: SongDataProvider {}
