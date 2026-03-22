//
//  HistoryClient.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 22/03/26.
//

import Foundation
import ComposableArchitecture
import SharedModels

// The interface — wraps your existing UseCase
struct HistoryClient {
    var fetchHistory: (_ year: Int, _ month: Int) async throws -> [BookingResult]
}

extension HistoryClient: DependencyKey {
    // Production — uses your existing UseCase unchanged
    static let liveValue = HistoryClient(
        fetchHistory: { year, month in
            try await FetchHistoryUseCase(
                repository: MockHistoryRepository()
            ).execute(year: year, month: month)
        }
    )
}

extension DependencyValues {
    var historyClient: HistoryClient {
        get { self[HistoryClient.self] }
        set { self[HistoryClient.self] = newValue }
    }
}
