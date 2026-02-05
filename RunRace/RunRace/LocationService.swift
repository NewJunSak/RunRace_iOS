//
//  LocationService.swift
//  RunRace
//
//  Created by BOMBSGIE on 1/26/26.
//

import Foundation
import CoreLocation
import Combine

protocol PointServable {
    /// 위,경도 Publisher
    var pointPublisher: AnyPublisher<Point, Never> { get }
    var locationErrorPublisher: AnyPublisher<AppErrorProtocol, Never> { get }
    
    func startUpdateLocation()
    func stopUpdateLocation()
    func setGameMode(_ mode: GameMode)
}

final class LocationService: NSObject {
    private let locationManager = CLLocationManager()
    private let locationSubject = PassthroughSubject<CLLocation, Never>()
    private let locationErrorSubject = PassthroughSubject<AppErrorProtocol, Never>()
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

extension LocationService: PointServable {
    var pointPublisher: AnyPublisher<Point, Never> {
        locationSubject
            .map {
                Point(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            }
            .eraseToAnyPublisher()
    }
    
    var locationErrorPublisher: AnyPublisher<AppErrorProtocol, Never> {
        locationErrorSubject
            .eraseToAnyPublisher()
    }
    
    func startUpdateLocation() {
        guard let gameMode = gameMode
        else {
            locationErrorSubject.send(LocationError.notSetGameMode)
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
            locationErrorSubject.send(LocationError.notAuthorized)
        @unknown default:
            break
        }
    }
}

// MARK: - Error

extension LocationService {
    enum LocationError: AppErrorProtocol {
        case notAuthorized
        case notSetGameMode
        
        var message: String {
            switch self {
            case .notAuthorized:
                return "위치 권한이 허용되어 있지 않습니다. 설정에서 위치 권한을 허용해주세요."
            case .notSetGameMode:
                return "달릴 거리가 지정되지 않았습니다."
            }
        }
        
        var action: ErrorAction {
            switch self {
            case .notAuthorized:
                return .alert
            case .notSetGameMode:
                return .none
            }
        }
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
