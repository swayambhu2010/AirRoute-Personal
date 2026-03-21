//
//  ActionButton.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI

// MARK: - ActionButton
// Yellow button used across all screens
// Title changes per screen context

struct ActionButton: View {

    let title: String
    let action: () -> Void
    var isLoading: Bool = false

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.yellow)
                    .frame(height: 52)

                if isLoading {
                    ProgressView()
                        .tint(.black)
                } else {
                    Text(title)
                        .font(.system(
                            size: 16,
                            weight: .semibold
                        ))
                        .foregroundColor(.black)
                }
            }
        }
        .disabled(isLoading)
        .padding(.horizontal, 16)
    }
}

#Preview {
    ActionButton(title: "Set A", action: {})
}
