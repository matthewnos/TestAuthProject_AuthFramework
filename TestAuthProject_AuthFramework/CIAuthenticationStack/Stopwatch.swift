//
//  Stopwatch.swift
//  TestAuthProject_AuthFramework
//
//  Created by Andrew Fairchild on 6/26/23.
//

import Foundation
import Combine

class Stopwatch: ObservableObject {
    /// String to show in UI
    @Published private(set) var message = "Not running"
    
    /// Is the timer running?
    @Published private(set) var isRunning = false
    
    var minutes: Int
    var repeatForever: Bool
    var onComplete: () -> ()
    
    /// Time that we're counting from
    private var startTime: Date?
    
    /// The timer
    private var timer: AnyCancellable?
    
    init(minutes: Int, repeatForever: Bool, onComplete: @escaping () -> (Void)) {
        self.minutes = minutes
        self.repeatForever = repeatForever
        self.onComplete = onComplete
        
        if startTime != nil {
            start()
        }
    }
}

// MARK: - Public Interface
extension Stopwatch {
    func start() {
        timer?.cancel()
        
        if startTime == nil {
            startTime = Date()
        }
        
        message = ""
        
        timer = Timer
            .publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard
                    let self = self,
                    let startTime = self.startTime
                else { return }
                
                let now = Date()
                let elapsed = now.timeIntervalSince(startTime)
                
                guard elapsed.magnitude < Double(minutes * 60) else {
                    self.stop()
                    onComplete()
                    if repeatForever {
                        start()
                    }
                    return
                }
                
                self.message = String(format: "%0.1f", elapsed)
            }
        
        isRunning = true
    }
    
    func stop() {
        timer?.cancel()
        timer = nil
        startTime = nil
        isRunning = false
        message = "Not running"
    }
}
