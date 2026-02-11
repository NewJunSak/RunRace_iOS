//
//  LocalNotifiactionService.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/11/26.
//

import UserNotifications

final class LocalNotifiactionService {
    private let unNotificationService = UNUserNotificationCenter.current()
    
    private func configureContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "게임이 진행 중입니다."
        content.body = "연결이 끊어질 수 있으니, 탭하여 게임으로 돌아오세요."
        return content
    }
}
