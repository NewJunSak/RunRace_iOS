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

//TODO: UseCase 구현 시, 해당 파일의 fileprivate으로 변경
extension Location {
    func convertToDistance(_ prevLocation: Location) -> Double {
        let current = CLLocation(latitude: latitude, longitude: longitude)
        let prev = CLLocation(latitude: prevLocation.latitude, longitude: prevLocation.longitude)
        return current.distance(from: prev)
    }
}
