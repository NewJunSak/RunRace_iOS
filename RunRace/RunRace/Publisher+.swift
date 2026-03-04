//
//  Publisher+.swift
//  RunRace
//
//  Created by BOMBSGIE on 3/4/26.
//

import Foundation
import Combine

extension Publisher {
    /// SwiftConcurrency로 된 비동기 작업을 Combine의 다운 스트림으로 전달하는 오퍼레이터
    func asyncMap<T>(_ transform: @escaping (Output) async -> T) -> Publishers.FlatMap<Future<T, Failure>, Self> {
        flatMap(maxPublishers: .max(1)) { output in
            Future { promise in
                Task {
                    let result = await transform(output)
                    promise(.success(result))
                }
            }
        }
    }
    
    func tryAsyncMap<T>(_ transform: @escaping (Output) async throws -> T) -> Publishers.FlatMap<Future<T, Failure>, Self> {
        flatMap(maxPublishers: .max(1)) { output in
            Future { promise in
                Task {
                    do {
                        let result = try await transform(output)
                        promise(.success(result))
                    } catch let error as Self.Failure {
                        promise(.failure(error))
                    }
                }
            }
        }
    }
}
