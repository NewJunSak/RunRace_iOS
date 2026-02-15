//
//  MatchmakerService.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/15/26.
//

import Combine
import GameKit

protocol MatchmakerServable {
    var modePublisher: AnyPublisher<MatchmakerMode, Never> { get }
    func makeRequest(_ max: Int)
}

final class MatchmakerService {
    private let modeSubject = PassthroughSubject<MatchmakerMode, Never>()
    
    
    private func configRequest(_ max: Int) -> GKMatchRequest {
        let gkRequest = GKMatchRequest()
        gkRequest.minPlayers = 2
        gkRequest.maxPlayers = max
        return gkRequest
    }
}

extension MatchmakerService: MatchmakerServable {
    var modePublisher: AnyPublisher<MatchmakerMode, Never> {
        modeSubject.eraseToAnyPublisher()
    }
    
    func makeRequest(_ max: Int) {
        let request = configRequest(max)
        modeSubject.send(.request(request))
    }
}
