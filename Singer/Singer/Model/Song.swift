//
//  Song.swift
//  Singer
//
//  Created by Daniel Gogozan on 07.11.2021.
//

import Foundation


struct Music: Codable{
    var results: [Song]
}

struct Song: Codable  {
    
    var id: Int
    var artist: String
    var name: String
    var collectionName: String
    var preview: String
    var poster: String
    
    enum CodingKeys: String, CodingKey {
        case id = "trackId"
        case artist = "artistName"
        case name = "trackName"
        case collectionName
        case preview = "previewUrl"
        case poster = "artworkUrl100"
    }
}

//extension Song {
//    init(id: Int, artist: String, name: String, collectionName: String, preview: String, poster: String) {
//        self.id = id
//        self.artist = artist
//        self.name = name
//        self.collectionName = collectionName
//        self.preview = preview
//        self.poster = poster
//    }
//}
