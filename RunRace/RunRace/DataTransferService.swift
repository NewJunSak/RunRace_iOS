//
//  DataTransferService.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/10/26.
//

import Combine
import Foundation
import GameKit

final class DataTransferService: NSObject {
    private let outputDataSubject = PassthroughSubject<(userId: String, Data), Never>()
    
    private var match: GKMatch? {
        didSet {
            match?.delegate = self
        }
    }
    
}

extension DataTransferService: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        outputDataSubject.send((player.gamePlayerID, data))
    }
}

extension DataTransferService {
    var outputRunStatusPublisher: AnyPublisher<(userId: String, RunStatus), Error> {
        outputDataSubject
            .tryMap { (userId, data) in
                let runningData = try JSONDecoder().decode(RunningData.self, from: data)
                return (userId, runningData)
            }
            .compactMap{ [weak self] id, data in
                guard let runStatus = self?.toRunStatus(from: data) else { return nil }
                return (id, runStatus)
            }
            .eraseToAnyPublisher()
    }
    
    func setMatch(_ match: GKMatch) {
        self.match = match
    }
    
    func sendData(with status: RunStatus) throws {
        let runningData = toRunningData(from: status)
        let data = try JSONEncoder().encode(runningData)
        try match?.sendData(toAllPlayers: data, with: .unreliable)
    }
    
    func endMatch() {
        match = nil
    }
}


// MARK: - Transfer Method

private extension DataTransferService {
    
    func toRunStatus(from runningData: RunningData) -> RunStatus? {
        if runningData.runState == .countDown { return .countDown }
        if runningData.runState == .giveUp { return .giveUp }
        guard let latitude = runningData.latitude,
              let longitude = runningData.longitude,
              let timestamp = runningData.timestamp
        else {
            return nil
        }
        
        let point = Point(latitude: latitude, longitude: longitude)
        
        switch runningData.runState {
        case .started:
            return .started(point: point, time: timestamp)
        case .running:
            return .running(point: point)
        case .finished:
            return .finished(point: point, time: timestamp)
        default:
            return nil
        }
    }
    
    func toRunningData(from status: RunStatus) -> RunningData {
        switch status {
        case .countDown:
            return RunningData(runState: .countDown)
        case .started(let point, let time):
            return RunningData(runState: .started, latitude: point.latitude, longitude: point.longitude, timestamp: time)
        case .running(let point):
            return RunningData(runState: .running, latitude: point.latitude, longitude: point.longitude)
        case .finished(let point, let time):
            return RunningData(runState: .finished, latitude: point.latitude, longitude: point.longitude, timestamp: time)
        case .giveUp:
            return RunningData(runState: .giveUp)
        }
    }
}
