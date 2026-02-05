//
//  RunStatus.swift
//  RunRace
//
//  Created by 김준성 on 2/2/26.
//

import Foundation

enum RunStatus {
    case countDown
    case started(point: Point, time: Date)
    case running(point: Point)
    case finished(point: Point, time: Date)
    case giveUp
}

extension RunStatus {
    var point: Point? {
        switch self {
        case .started(point: let point, time: _),
                .running(point: let point),
                .finished(point: let point, time: _):
            return point
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
