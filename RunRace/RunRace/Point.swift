//
//  Point.swift
//  RunRace
//
//  Created by BOMBSGIE on 1/26/26.
//

import CoreLocation

/// 좌표 Entity
struct Point {
    let latitude: Double
    let longitude: Double
}

extension Point {
    func distance(from other: Point) -> Double {
        let selfLocation = CLLocation(latitude: latitude, longitude: longitude)
        let otherLocation = CLLocation(latitude: other.latitude, longitude: other.latitude)
        let distance = selfLocation.distance(from: otherLocation)
        return distance
    }
}
