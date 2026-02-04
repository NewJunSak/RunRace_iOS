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
    private(set) var locations: [Location]
    
    init(
        id: String,
        nickname: String,
        distance: Double,
        status: RunStatus,
        startTime: Date?,
        finishTime: Date?,
        locations: [Location]
    ) {
        self.id = id
        self.nickname = nickname
        self.distance = distance
        self.status = status
        self.startTime = startTime
        self.finishTime = finishTime
        self.locations = locations
    }
    
    convenience init(id: String, nickname: String) {
        self.init(
            id: id, nickname: nickname,
            distance: 0, status: .countDown,
            startTime: nil, finishTime: nil,
            locations: []
        )
    }
    
    func update(status: RunStatus) {
        switch status {
        case .started(location: let location, time: let time):
            startTime = time
            updateDistance(from: location)
        case .running(location: let location):
            updateDistance(from: location)
        case .finished(location: let location, time: let time):
            finishTime = time
            updateDistance(from: location)
        default:
            return
        }
    }
    
    private func updateDistance(from currentLocation: Location) {
        guard let lastLocation = locations.last else {
            locations.append(currentLocation)
            return
        }
        
        distance += currentLocation.distance(from: lastLocation)
        locations.append(currentLocation)
    }
}
