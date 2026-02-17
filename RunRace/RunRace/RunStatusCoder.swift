//
//  RunStatusCoder.swift
//  RunRace
//
//  Created by 김준성 on 2/17/26.
//

import Foundation

struct RunStatusCoder {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(encoder: JSONEncoder, decoder: JSONDecoder) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    init() {
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        decoder.dateDecodingStrategy = .millisecondsSince1970
    }
    
    func encode(_ status: RunStatus, userId: String) throws -> Data {
        let dto = RunStatusDTO(userId: userId, runStatus: status)
        return try encoder.encode(dto)
    }
    
    func decode(_ data: Data) throws -> RunStatus {
        let dto = try decoder.decode(RunStatusDTO.self, from: data)
        return try dto.toDomain()
    }
}
