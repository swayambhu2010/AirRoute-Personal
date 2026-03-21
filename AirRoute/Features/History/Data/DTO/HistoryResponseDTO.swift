//
//  HistoryResponseDTO.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import Foundation

// Response is an array of BookingResponseDTO
// GET /books?year=2020&month=11
// So we just reuse BookingResponseDTO as array
typealias HistoryResponseDTO = [BookingResponseDTO]
