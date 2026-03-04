//
//  UpdateRunningStatusUseCase.swift
//  RunRace
//
//  Created by BOMBSGIE on 3/4/26.
//

import Foundation
import Combine

final class UpdateRunningStatusUseCase {
    private let pointService: PointServable
    private let dataTransferService: DataTransferService
    private let runningSession: RunningSession
    
    // 임시의 최종 달릴 거리
    private let limitDistance = 100.0
    private var task: Task<Void, Never>?
    
    init(
        pointService: PointServable,
        dataTransferService: DataTransferService,
        runningSession: RunningSession
    ) {
        self.pointService = pointService
        self.dataTransferService = dataTransferService
        self.runningSession = runningSession
    }
}

// MARK: - Swift Concurrency

extension UpdateRunningStatusUseCase {
    func updateStatusWithSwiftConcurrency() {
        task = Task {
            do {
                //TODO: 현재 사용자의 ID관리
                guard let runner = await runningSession.fetchRunner(id: "temp") else { return }
                
                for await point in pointService.pointPublisher.values {
                    let status: RunStatus
                    
                    switch  runner.status {
                    case .countDown:
                        status = .started(point: point, time: Date())
                    case .started:
                        status = .running(point: point)
                    case .running:
                        // 현재 거리에 따른 finished, running 처리
                        if runner.newDistance(point) < limitDistance {
                            status = .running(point: point)
                        } else {
                            status = .finished(point: point, time: Date())
                        }
                    case .finished, .giveUp:
                        task?.cancel()
                    }
                    runner.update(status: status)
                    try dataTransferService.sendData(with: status)
                }
            } catch {
                //TODO: Error
            }
        }
    }
}


private extension Runner {
    func newDistance(_ currentPoint: Point) -> Double {
        guard let lastPoint = self.points.last else { return 0 }
        return distance + currentPoint.distance(from: lastPoint)
    }
}
