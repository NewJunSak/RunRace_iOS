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
    /// 위,경도 Publisher
    var locationPublisher: AnyPublisher<Location, Never> { get }
    
    func startUpdateLocation()
    func stopUpdateLocation()
    func updateDistancefilter(_ distance: RunDistance)
}

final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 1.0
    }
}

extension LocationService: LocationServable {
    var locationPublisher: AnyPublisher<Location, Never> {
        locationSubject
            .map {
                Location(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            }
            .eraseToAnyPublisher()
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
        guard let currentLocation = locations.last else { return }
        locationSubject.send(currentLocation)
    }
}
