//
//  LocationService.swift
//  RunRace
//
//  Created by BOMBSGIE on 1/26/26.
//

import Foundation
import CoreLocation
import Combine

protocol LocationServable {
    var locationPublisher: AnyPublisher<Location, Never> { get }
    func startUpdateLocation()
    func stopUpdateLocation()
    func updateDistancefilter(_ distance: RunDistance)
}

final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private let locationSubject = CurrentValueSubject<CLLocation?, Never>(nil)
    private let distanceSubject = CurrentValueSubject<Double, Never>(0.0)
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0
    }
}

extension LocationService: LocationServable {
    var locationPublisher: AnyPublisher<Location, Never> {
        locationSubject
            .compactMap { $0?.coordinate }
            .map {
                Location(latitude: $0.latitude, longitude: $0.longitude)
            }
            .eraseToAnyPublisher()
    }
    
    var distancePublisher: AnyPublisher<Double, Never> {
        distanceSubject.eraseToAnyPublisher()
    }
    
    func startUpdateLocation() {
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
    }
    /// 외부에서 사용자가 달릴 거리에 따른 DistanceFilter
    func updateDistancefilter(_ distance: RunDistance) {
        locationManager.distanceFilter = distance.distanceFilter
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let clLocation = locations.last else { return }
        let location = Location(latitude: clLocation.coordinate.latitude, longitude: clLocation.coordinate.longitude)
        locationSubject.send(location)
    }
}
