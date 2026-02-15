//
//  MatchmakerMode.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/12/26.
//

import GameKit

enum MatchmakerMode {
    case invite(GKInvite)
    case request(GKMatchRequest)
}

extension MatchmakerMode: Identifiable {
    var id: Int {
        switch self {
        case .invite(let invite):
            return invite.hash
        case .request(let request):
            return request.hash
        }
    }
}
