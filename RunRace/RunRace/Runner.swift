//
//  Runner.swift
//  RunRace
//
//  Created by 김준성 on 2/2/26.
//

import Foundation

final class Runner {
    let id: String
    let nickname: String
    var timeLapsed: TimeInterval {
        guard let startTime else {
            return 0;
        }
        
        guard let finishTime else {
            return Date().timeIntervalSince(startTime)
        }
        
        return finishTime.timeIntervalSince(startTime)
    }
    
    private(set) var distance: Double
    private(set) var status: RunStatus
    private(set) var startTime: Date?
    private(set) var finishTime: Date?
    private(set) var points: [Point]
    
    init(
        id: String,
        nickname: String,
        distance: Double,
        status: RunStatus,
        startTime: Date?,
        finishTime: Date?,
        points: [Point]
    ) {
        self.id = id
        self.nickname = nickname
        self.distance = distance
        self.status = status
        self.startTime = startTime
        self.finishTime = finishTime
        self.points = points
    }
    
    convenience init(id: String, nickname: String) {
        self.init(
            id: id, nickname: nickname,
            distance: 0, status: .countDown,
            startTime: nil, finishTime: nil,
            points: []
        )
    }
    
    func update(status: RunStatus) {
        switch status {
        case .started(point: let point, time: let time):
            startTime = time
            updateDistance(from: point)
        case .running(point: let point):
            updateDistance(from: point)
        case .finished(point: let point, time: let time):
            finishTime = time
            updateDistance(from: point)
        default:
            return
        }
    }
    
    private func updateDistance(from currentPoint: Point) {
        guard let lastPoint = points.last else {
            points.append(currentPoint)
            return
        }
        
        distance += currentPoint.distance(from: lastPoint)
        points.append(currentPoint)
    }
}
