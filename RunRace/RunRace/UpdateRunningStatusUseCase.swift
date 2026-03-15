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

// MARK: - Combine

extension UpdateRunningStatusUseCase {
    var statusUpdatePublisher: AnyPublisher<RunStatus?, Never> {
        pointService.pointPublisher
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
           .eraseToAnyPublisher()
    }
}

// MARK: - Runner+

private extension Runner {
    func newDistance(_ currentPoint: Point) -> Double {
        guard let lastPoint = self.points.last else { return 0 }
        return distance + currentPoint.distance(from: lastPoint)
    }
}
