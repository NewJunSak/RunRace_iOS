//
//  LocalNotifiactionService.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/11/26.
//

import UserNotifications

protocol NotificationServable {
    func requestPermission()
    func scheduleNotification()
    func cancelNotification()
}

//TODO: DataTransferService에서 현재 매치가 진행중인지 Bool Subject로 처리 필요
final class LocalNotifiactionService {
    private let unNotificationService = UNUserNotificationCenter.current()
    
    private func configureContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = Constants.title.value
        content.body = Constants.body.value
        return content
    }
}

extension LocalNotifiactionService: NotificationServable {
    func requestPermission() {
        unNotificationService.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print("\(error)")
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

private extension LocalNotifiactionService {
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
