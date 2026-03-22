//
//  LocationDetailsState.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import SharedModels

struct LocationDetailState {

    // MARK: - Data
    var location: LocationPoint? = nil
    var locationType: LocationType = .locationA

    // MARK: - Nickname
    private(set) var nickname: String = ""
    private(set) var isNicknameTooLong: Bool = false
    private(set) var isSaveEnabled: Bool = false

    // MARK: - Error
    var errorMessage: String? = nil

    // MARK: - Nickname Update
    // Single method owns ALL nickname validation logic
    // ViewModel just calls this — no inline logic
    mutating func updateNickname(_ text: String) {
        let trimmed = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        nickname = text
        isNicknameTooLong = text.count > 20

        // isSaveEnabled uses local isNicknameTooLong
        // No ordering dependency ✅
        isSaveEnabled = !trimmed.isEmpty && !isNicknameTooLong
    }

    // MARK: - Computed
    var typeLabel: String {
        switch locationType {
        case .locationA: return "A"
        case .locationB: return "B"
        }
    }

    var locationName: String {
        location?.displayName ?? ""
    }

    var aqiValue: String {
        guard let aqi = location?.aqi else { return "0" }
        return "\(aqi)"
    }
}
