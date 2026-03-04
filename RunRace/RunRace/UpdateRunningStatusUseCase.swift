//
//  UpdateRunningStatusUseCase.swift
//  RunRace
//
//  Created by BOMBSGIE on 3/4/26.
//

import Foundation

final class UpdateRunningStatusUseCase {
    private let pointService: PointServable
    private let dataTransferService: DataTransferService
    private let runningSession: RunningSession
    
    init(
        pointService: PointServable,
        dataTransferService: DataTransferService,
        runningSession: RunningSession
    ) {
        self.pointService = pointService
        self.dataTransferService = dataTransferService
        self.runningSession = runningSession
    }
}
