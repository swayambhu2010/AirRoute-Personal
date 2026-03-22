//
//  LocationLabelView.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI
import SharedModels

// MARK: - LocationLabelView
// A or B label at bottom of Screen 1
// Tappable — navigates to Screen 2 or Screen 5

struct LocationLabelView: View {

    let type: LocationType
    let locationName: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(typeText)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.black)

                Text(locationName ?? "")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .shadow(
                        color: .black.opacity(0.1),
                        radius: 4,
                        x: 0,
                        y: 2
                    )
            )
        }
    }

    private var typeText: String {
        switch type {
        case .locationA: return "A"
        case .locationB: return "B"
        }
    }
}

#Preview {
    LocationLabelView(type: .locationA, locationName: "Home", onTap: { })
}
