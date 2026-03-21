//
//  MockUpdateNicknameUseCase.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
@testable import AirRoute

final class MockUpdateNicknameUseCase: UpdateNicknameUseCaseProtocol {

    // MARK: - Control
    // nil  = success (no error thrown)
    // non-nil = error thrown
    var errorToThrow: Error? = nil

    // MARK: - Tracking
    var callCount = 0
    var lastNickname: String?
    var lastLocation: LocationPoint?

    // MARK: - Execute
    func execute(
        nickname: String,
        for location: LocationPoint
    ) throws {
        callCount += 1
        lastNickname = nickname
        lastLocation = location
        if let error = errorToThrow {
            throw error
        }
    }
}
