//
//  SongViewModel.swift
//  Singer
//
//  Created by Daniel Gogozan on 08.11.2021.
//

import Foundation


class SongViewModel: NSObject {
    
    private var service: MusicService
    
    private let operationQueue = OperationQueue()
    
    var downloadProgress: Box<Float> = Box(0.0)
    
    var downloadDestionation: URL?
    
    var downloadState: Box<DownloadState> = Box(.none)
    
    var discoveredSong: Box<Song?> = Box(nil)
    
    var discoveredSongPreview: Box<URL?> = Box(nil)
    
    init(service: MusicService) {
        self.service = service
        super.init()
    }
    
    func checkDownloadDestination(songId: Int) {
        print("Downloads count: \(service.downloads.count)")
        if let destination = service.getDownloadDestination(for: songId) {
            self.downloadDestionation = destination
            self.downloadState.value = .finished
        }
    }
    
    func downloadSong(songId: Int, preview: String) {
        service.download(songId: songId, preview: preview) { [weak self] progress in
            self?.downloadProgress.value = progress
        } completion: { url in
            self.downloadDestionation = url
            self.downloadState.value = .finished
            print(self.service.downloads.count)
        }
    }
    
    func refreshState() {
        self.downloadState.value = .none
    }
    
    func cancelDownload(songId: Int) {
        service.cancelDownload(with: songId)
        self.downloadState.value = .none
    }
    
    func pauseDownload(songId: Int) {
        service.pauseDownload(with: songId)
        self.downloadState.value = .paused
    }
    
    func resumeDownload(songId: Int) {
        service.resumeDownload(with: songId)
        self.downloadState.value = .downloading
    }
    
    // share data using adapter
    func getSong() {
        operationQueue.maxConcurrentOperationCount = 1
        
        let songRequestOperation = SongRequestOperation()
        let previewDownloadOperation = PreviewDownloadOperation { url in
            self.downloadDestionation = url
        }
        let adapter = BlockOperation() { [unowned songRequestOperation, unowned previewDownloadOperation] in
            previewDownloadOperation.song = songRequestOperation.song
        }
        
        previewDownloadOperation.completionBlock = { [weak self] in
            self?.discoveredSong.value = previewDownloadOperation.song
        }
        
        adapter.addDependency(songRequestOperation)
        previewDownloadOperation.addDependency(adapter)
        
        operationQueue.addOperations([songRequestOperation, previewDownloadOperation, adapter], waitUntilFinished: true)
    }
    
    
    // share data using protocols
    func getSong2() {
        operationQueue.maxConcurrentOperationCount = 1
        let songRequestOperation = SongRequestOperation()
        let previewDownloadOperation = PreviewDownloadOperation { url in
            self.downloadDestionation = url
        }
        previewDownloadOperation.addDependency(songRequestOperation)
        previewDownloadOperation.completionBlock = { [weak self] in
            self?.discoveredSong.value = previewDownloadOperation.song
        }
        
        operationQueue.addOperation(songRequestOperation)
        operationQueue.addOperation(previewDownloadOperation)
        operationQueue.waitUntilAllOperationsAreFinished()
    }
}
