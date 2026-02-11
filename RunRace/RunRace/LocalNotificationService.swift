//
//  LocalNotificationService.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/11/26.
//

import UserNotifications
import Combine

protocol NotificationServable {
    var errorPublisher: AnyPublisher<AppErrorProtocol, Never> { get }
    
    func requestPermission()
    func scheduleNotification()
    func cancelNotification()
}

//TODO: DataTransferService에서 현재 매치가 진행중인지 Bool Subject로 처리 필요
final class LocalNotificationService {
    private let unNotificationService = UNUserNotificationCenter.current()
    private let errorSubject = PassthroughSubject<AppErrorProtocol, Never>()
    
    private func configureContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Constants.title.value
        content.body = Constants.body.value
        return content
    }
}

extension LocalNotificationService: NotificationServable {
    var errorPublisher: AnyPublisher<AppErrorProtocol, Never> {
        errorSubject
            .eraseToAnyPublisher()
    }
    
    func requestPermission() {
        unNotificationService.requestAuthorization(options: [.alert, .sound]) {[weak self] granted, error in
            if let error = error {
                print("\(error)")
            }
            
            if granted == false {
                self?.errorSubject.send(NotificationError.isNotGranted)
            }
        }
    }
    
    func scheduleNotification() {
        let content = configureContent()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: Constants.notificationId.value, content: content, trigger: trigger)
        unNotificationService.add(request)
    }
    
    func cancelNotification() {
        unNotificationService.removePendingNotificationRequests(withIdentifiers: [Constants.notificationId.value])
    }
}

// MARK: - 알림 권한에 따른 에러

extension LocalNotificationService {
    enum NotificationError: AppErrorProtocol {
        case isNotGranted
        
        var message: String {
            switch self {
            case .isNotGranted:
                "알림 권한이 거부되었습니다. 앱을 켜진 상태로 유지하여 게임 연결이 끊기지 않게 해주세요."
            }
        }
        
        var action: ErrorAction {
            switch self {
            case .isNotGranted:
                return .alert
            }
        }
    }
}

private extension LocalNotificationService {
    enum Constants {
        case notificationId
        case title
        case body
        
        var value: String {
            switch self {
            case .notificationId:
                return "disconnectWarning"
            case .title:
                return "게임이 진행 중입니다."
            case .body:
                return "연결이 끊어질 수 있으니, 탭하여 게임으로 돌아오세요."
            }
        }
    }
}
