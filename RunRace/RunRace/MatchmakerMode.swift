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
