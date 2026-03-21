//
//  HistoryError.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

enum HistoryError: LocalizedError {

    // MARK: - Validation Errors
    case invalidMonth       // month not between 1-12
    case invalidYear        // year is in the future

    // MARK: - Error Description
    var errorDescription: String? {
        switch self {
        case .invalidMonth:
            return "Month must be between 1 and 12"
        case .invalidYear:
            return "Year cannot be in the future"
        }
    }
}
