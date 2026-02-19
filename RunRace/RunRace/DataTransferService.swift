//
//  DataTransferService.swift
//  RunRace
//
//  Created by BOMBSGIE on 2/10/26.
//

import Combine
import Foundation
import GameKit

final class DataTransferService: NSObject {
    private let outputDataSubject = PassthroughSubject<(userId: String, Data), Never>()
    private let runStatusCoder = RunStatusCoder()
    
    private var match: GKMatch? {
        didSet {
            match?.delegate = self
        }
    }
    
}

extension DataTransferService: GKMatchDelegate {
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        outputDataSubject.send((player.gamePlayerID, data))
    }
}

extension DataTransferService {
    var outputRunStatusPublisher: AnyPublisher<(userId: String, RunStatus), Error> {
        outputDataSubject
            .tryMap { [weak self] (userId, data) in
                guard let self = self else { throw URLError(.cannotDecodeContentData) }
                let status = try self.runStatusCoder.decode(data)
                return (userId, status)
            }
            .eraseToAnyPublisher()
    }
    
    func setMatch(_ match: GKMatch) {
        self.match = match
    }
    
    func sendData(with status: RunStatus) throws {
        let data = try runStatusCoder.encode(status)
        try match?.sendData(toAllPlayers: data, with: .unreliable)
    }
    
    func endMatch() {
        match = nil
    }
}

