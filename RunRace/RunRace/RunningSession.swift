//
//  RunningSession.swift
//  RunRace
//
//  Created by 김준성 on 2/5/26.
//

import Combine
import Foundation

actor RunningSession {
    private nonisolated let runnerSubject: PassthroughSubject<Runner, Never>
    private var runnerMap: [String: Runner]
    
    nonisolated var runnerPublisher: AnyPublisher<Runner, Never> {
        runnerSubject.eraseToAnyPublisher()
    }
    
    init() {
        self.runnerSubject = .init()
        self.runnerMap = [:]
    }
    
    func setRunners(from runners: [Runner]) {
        runners.forEach { runner in
            runnerMap[runner.id] = runner
            runnerSubject.send(runnerMap[runner.id]!)
        }
    }
    
    func update(status: RunStatus, for runnerId: String) {
        guard let runner = runnerMap[runnerId] else { return }
        Task {
            await runner.update(status: status)
            runnerSubject.send(runner)
        }
    }
    
    func reset() {
        runnerMap.removeAll()
    }
}
