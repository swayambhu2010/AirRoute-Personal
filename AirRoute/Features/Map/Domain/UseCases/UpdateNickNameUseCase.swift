//
//  UpdateNickNameUseCase.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

// MARK: - Protocol
protocol UpdateNicknameUseCaseProtocol {
    func execute(
        nickname: String,
        for location: LocationPoint
    ) throws
}

// MARK: - Implementation
final class UpdateNicknameUseCase: UpdateNicknameUseCaseProtocol {

    // MARK: - Dependencies
    private let repository: LocationRepositoryProtocol

    // MARK: - Init
    init(repository: LocationRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Execute
    /// Saves or clears nickname for a cached location
    /// Business Rules:
    /// 1. Nickname max 20 characters
    /// 2. Empty nickname → clears existing nickname
    /// 3. Location must exist in cache
    /// Called when:
    /// User taps Save on Screen 2
    func execute(
        nickname: String,
        for location: LocationPoint
    ) throws {

        // Rule 1: Nickname max 20 characters
        let trimmed = nickname.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard trimmed.count <= 20 else {
            throw LocationError.nicknameTooLong
        }

        // Rule 2: Pass trimmed value
        // Empty string → repository sets nil
        try repository.updateNickname(
            trimmed,
            for: location
        )
    }
}
