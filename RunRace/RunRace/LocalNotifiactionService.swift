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
        content.title = "게임이 진행 중입니다."
        content.body = "연결이 끊어질 수 있으니, 탭하여 게임으로 돌아오세요."
        return content
    }
}
