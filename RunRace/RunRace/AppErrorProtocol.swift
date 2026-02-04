//
//  AppErrorProtocol.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/3/26.
//

import Foundation

protocol AppErrorProtocol: LocalizedError {
    /// 사용자에게 보여질 메세지
    var message: String { get }
    /// 에러 발생 시, 뷰에 적용될 액션
    var action: ErrorAction { get }
}

extension AppErrorProtocol {
    var localizedDescription: String? {
        return message
    }
}

// MARK: - ErrorAction

enum ErrorAction {
    case none
    case alert
}
