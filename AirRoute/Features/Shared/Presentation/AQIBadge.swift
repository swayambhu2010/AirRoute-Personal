//
//  AQIBadge.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI

// MARK: - AQIBadgeView
// Displays AQI value
// Used on Screen 1 (top right)
// and Screen 2 (detail)

struct AQIBadgeView: View {

    let aqi: Int

    var body: some View {
        HStack {
            Text("aqi")
                .foregroundColor(.secondary)
            
            Text("\(aqi)")
                .foregroundColor(.black)
        }
        .font(.system(size: 20, weight: .medium))
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
    }
}

#Preview {
    AQIBadgeView(aqi: 25)
}
