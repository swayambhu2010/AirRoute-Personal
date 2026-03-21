//
//  HistoryAction.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

enum HistoryAction {
    case onAppear
    case historyFetched([BookingResult])
    case fetchFailed(Error)
    case cellTapped(BookingResult)
    case dismissTapped
    case errorDismissed
}
