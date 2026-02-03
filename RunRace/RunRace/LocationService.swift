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
    var locationPublisher: AnyPublisher<Location, Error> { get }
    
    func startUpdateLocation()
    func stopUpdateLocation()
    func setGameMode(_ mode: GameMode)
}

final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, Error>()
    private var gameMode: GameMode?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    private func setTrackingPrecision(_ mode: GameMode) {
        locationManager.desiredAccuracy = mode.locationAccuracy
        locationManager.distanceFilter = mode.distanceFilter
    }
}

extension LocationService: LocationServable {
    var locationPublisher: AnyPublisher<Location, Error> {
        locationSubject
            .map {
                Location(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            }
            .eraseToAnyPublisher()
    }
    
    func startUpdateLocation() {
        guard let gameMode = gameMode
        else {
            locationSubject.send(completion: .failure(LocationError.notSetGameMode))
            return
        }
        setTrackingPrecision(gameMode)
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdateLocation() {
        locationManager.stopUpdatingLocation()
        gameMode = nil
    }
    /// 외부에서 사용자가 달릴 거리 설정
    func setGameMode(_ mode: GameMode) {
        gameMode = mode
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        locationSubject.send(currentLocation)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            break
        case .denied, .restricted:
            locationSubject.send(completion: .failure(LocationError.notAuthorized))
        @unknown default:
            break
        }
    }
}

extension LocationService {
    enum LocationError: Error {
        case notSetGameMode
        case notAuthorized
    }
}

// MARK: - GameMode+

private extension GameMode {
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
    
    var locationAccuracy: CLLocationSpeedAccuracy {
        return kCLLocationAccuracyBest
    }
}
