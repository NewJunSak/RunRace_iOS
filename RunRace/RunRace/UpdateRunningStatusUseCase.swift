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
    // Concurrency
    private var task: Task<Void, Never>?
    // Combine
    private var cancellable: AnyCancellable?
    
    init(
        pointService: PointServable,
        dataTransferService: DataTransferService,
        runningSession: RunningSession
    ) {
        self.pointService = pointService
        self.dataTransferService = dataTransferService
        self.runningSession = runningSession
    }
    
    deinit {
        task?.cancel()
        task = nil
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
                        pointService.stopUpdatingPoint()
                        task?.cancel()
                        return
                    }
                    //runner가 클래스라 자체에서 업데이트 하도록 하긴 했는데, runningSession으로 접근해서 업데이트하는 것이 좋은지 고민
                    runner.update(status: status)
                    try dataTransferService.sendData(with: status)
                }
            } catch {
                //TODO: Error
            }
        }
    }
}


// MARK: - Combine

extension UpdateRunningStatusUseCase {
    func updateStatusWithCombine() {
        cancellable = pointService.pointPublisher
            .tryAsyncMap { [weak self] point -> RunStatus? in
                guard let self,
                      let runner = await self.runningSession.fetchRunner(id: "temp")
                else {
                    return nil
                }
                
                let status: RunStatus
                
                switch runner.status {
                case .countDown:
                    status = .started(point: point, time: Date())
                case .started:
                    status = .running(point: point)
                case .running:
                    if runner.newDistance(point) < self.limitDistance {
                        status = .running(point: point)
                    } else {
                        status = .finished(point: point, time: Date())
                    }
                case .finished, .giveUp:
                    return runner.status
                }
                // sink 오퍼레이터에서 Task를 만들어 사용 시, 각각의 Task 생성으로 인해 처리 순서가 보장되지 않음
                await runningSession.update(status: status, for: "temp")
                try dataTransferService.sendData(with: status)
                return status
            }
            .sink {[weak self] status in
                guard let status else { return }
                switch status {
                case .finished, .giveUp:
                    self?.pointService.stopUpdatingPoint()
                    self?.cancellable?.cancel()
                default :
                    break
                }
            }
        
    }
}

// MARK: - Runner+

private extension Runner {
    func newDistance(_ currentPoint: Point) -> Double {
        guard let lastPoint = self.points.last else { return 0 }
        return distance + currentPoint.distance(from: lastPoint)
    }
}
