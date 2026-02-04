//
//  RunStatus.swift
//  RunRace
//
//  Created by 김준성 on 2/2/26.
//

import Foundation

enum RunStatus {
    case countDown
    case started(location: Location, time: Date)
    case running(location: Location)
    case finished(location: Location, time: Date)
    case giveUp
}

extension RunStatus {
    var location: Location? {
        switch self {
        case .started(location: let location, time: _),
                .running(location: let location),
                .finished(location: let location, time: _):
            return location
        default:
            return nil
        }
    }
    
    var isRunning: Bool {
        switch self {
        case .started, .running:
            return true
        default:
            return false
        }
    }
    
    var isFinished: Bool {
        switch self {
        case .finished:
            return true
        default:
            return false
        }
    }
}
