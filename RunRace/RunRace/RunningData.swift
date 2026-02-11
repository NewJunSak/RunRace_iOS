//
//  RunningData.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/9/26.
//

import Foundation

struct RunningData: Codable {
    let runState: RunState
    let latitude: Double?
    let longitude: Double?
    let timestamp: Date?

    init(
        runState: RunState,
        latitude: Double? = nil,
        longitude: Double? = nil,
        timestamp: Date? = nil
    ) {
        self.runState = runState
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
    
}

extension RunningData {
    enum RunState: String, Codable {
        case countDown
        case started
        case running
        case finished
        case giveUp
    }
}
