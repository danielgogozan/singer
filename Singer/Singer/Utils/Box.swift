//
//  Box.swift
//  Singer
//
//  Created by Daniel Gogozan on 07.11.2021.
//

import Foundation

final class Box<T> {

    typealias Listener = (T) -> Void
    var listner: Listener?
    
    var value: T {
        didSet {
            listner?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: Listener?) {
        self.listner = listener
        listener?(value)
    }
    
}
