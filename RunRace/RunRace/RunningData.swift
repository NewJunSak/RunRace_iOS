//
//  RunningData.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/9/26.
//

import Foundation

struct RunningData: Codable {
    let userId: String
    let runState: RunState
    let latitude: Double?
    let longitude: Double?

    init(
        userId: String,
        runState: RunState,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) {
        self.userId = userId
        self.runState = runState
        self.latitude = latitude
        self.longitude = longitude
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
