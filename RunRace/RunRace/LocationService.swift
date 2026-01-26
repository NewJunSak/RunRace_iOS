//
//  LocationService.swift
//  RunRace
//
//  Created by BOMBSGIE on 1/26/26.
//

import Foundation
import CoreLocation
import Combine

final class LocationService: NSObject {
    private let locationSubject = PassthroughSubject<Location, Never>()
    private let locationManager = CLLocationManager()
    
    var locationPublisher: AnyPublisher<Location, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0
    }
    
    func startUpdateLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let clLocation = locations.last else { return }
        let location = Location(latitude: clLocation.coordinate.latitude, longitude: clLocation.coordinate.longitude)
        locationSubject.send(location)
    }
}
