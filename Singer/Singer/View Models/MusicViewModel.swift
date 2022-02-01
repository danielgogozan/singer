//
//  MusicViewModel.swift
//  Singer
//
//  Created by Daniel Gogozan on 07.11.2021.
//

import Foundation

class MusicViewModel: NSObject {
    
    private var service: MusicService
    
    let music: Box<[Song]> = Box([])
    
    init(service: MusicService) {
        self.service = service
        super.init()
        self.getMusic()
    }
    
    func getMusic(query: String = "never") {
        service.getMusic(query: query) { [weak self] result in
            switch result {
            case .success(let songs):
                self?.music.value = songs
            case .failure(let error):
                print(error)
            }
        }
    }
}
