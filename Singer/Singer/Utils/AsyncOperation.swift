//
//  AsyncOperation.swift
//  Singer
//
//  Created by Daniel Gogozan on 09.11.2021.
//

import Foundation

extension AsyncOperation {
  enum State: String {
    case ready, executing, finished

    fileprivate var keyPath: String {
      "is\(rawValue.capitalized)"
    }
  }
}

// Implementation for creating an async operation
class AsyncOperation: Operation {
    
  /// State management creation
  var state = State.ready {
    willSet {
      willChangeValue(forKey: newValue.keyPath)
      willChangeValue(forKey: state.keyPath)
    }
    didSet {
      didChangeValue(forKey: oldValue.keyPath)
      didChangeValue(forKey: state.keyPath)
    }
  }

  /// Override properties
  override var isReady: Bool {
    return super.isReady && state == .ready
  }

  override var isExecuting: Bool {
    return state == .executing
  }

  override var isFinished: Bool {
    return state == .finished
  }

  override func cancel() {
    state = .finished
  }

  override var isAsynchronous: Bool {
    return true
  }

    /// Override start
  override func start() {
    if isCancelled {
      state = .finished
      return
    }
    main()
    state = .executing
  }
}
