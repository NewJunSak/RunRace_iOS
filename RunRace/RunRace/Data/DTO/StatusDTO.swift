//
//  StatusDTO.swift
//  RunRace
//
//  Created by 김준성 on 2/17/26.
//

import Foundation

struct RunStatusDTO: Codable {
    let userId: String
    let status: StatusType
    let time: Date?
    let latitude: Double?
    let longitude: Double?
    
    init(userId: String, runStatus: RunStatus) {
        self.userId = userId
        self.status = StatusType(from: runStatus)
        self.latitude = runStatus.point?.latitude
        self.longitude = runStatus.point?.longitude
        self.time = runStatus.time
    }
}

extension RunStatusDTO {
    enum StatusType: String, Codable {
        case countDown
        case started
        case running
        case finished
        case giveUp
        
        init(from runStatus: RunStatus) {
            switch runStatus {
            case .countDown: self = .countDown
            case .started: self = .started
            case .running: self = .running
            case .finished: self = .finished
            case .giveUp: self = .giveUp
            }
        }
    }
    
    func toDomain() throws -> RunStatus {
        let point: Point? = {
            guard let lat = latitude, let lon = longitude else { return nil }
            return Point(latitude: lat, longitude: lon)
        }()
        
        switch status {
        case .countDown:
            return .countDown
            
        case .started:
            guard let point, let time else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: [],
                          debugDescription: "started requires point and time")
                )
            }
            return .started(point: point, time: time)
            
        case .running:
            guard let point else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: [],
                          debugDescription: "running requires point")
                )
            }
            return .running(point: point)
            
        case .finished:
            guard let point, let time else {
                throw DecodingError.dataCorrupted(
                    .init(codingPath: [],
                          debugDescription: "finished requires point and time")
                )
            }
            return .finished(point: point, time: time)
            
        case .giveUp:
            return .giveUp
        }
    }
}

private extension RunStatusDTO {
    enum CodingKeys: String, CodingKey {
        case userId, status, time, latitude, longitude
    }
}
