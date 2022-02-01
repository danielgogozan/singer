//
//  SongCellViewModel.swift
//  Singer
//
//  Created by Daniel Gogozan on 09.11.2021.
//

import UIKit

class SongCellViewModel: NSObject {
    
    var image: Box<UIImage> = Box(UIImage(named: "song-icon")!)
    
    func downloadImage(poster: String) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            if let url = URL(string: poster),
               let data = try? Data(contentsOf: url),
               let img = UIImage(data: data) {
                self?.image.value = img
            }
        }
    }
}
