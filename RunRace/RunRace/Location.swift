//
//  Location.swift
//  RunRace
//
//  Created by BOMBSGIE on 1/26/26.
//

import CoreLocation

/// 좌표 Entity
struct Location {
    let latitude: Double
    let longitude: Double
}

extension Location {
    func distance(from other: Location) -> Double {
        let selfLocation = CLLocation(latitude: latitude, longitude: longitude)
        let otherLocation = CLLocation(latitude: other.latitude, longitude: other.latitude)
        let distance = selfLocation.distance(from: otherLocation)
        return distance
    }
}
