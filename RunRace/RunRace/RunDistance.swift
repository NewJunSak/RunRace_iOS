//
//  RunDistance.swift
//  RunRace
//
//  Created by BOMBSGIE on 1/26/26.
//

enum RunDistance {
    case m100
    case m300
    case m500
    case km1
    case km3
    case km5
    
    var distanceFilter: Double {
        switch self {
        case .m100, .m300:
            return 1.0
        case .m500:
            return 2.0
        case .km1:
            return 3.0
        case .km3:
            return 5.0
        case .km5:
            return 10.0
        }
    }
}
