//
//  LocationDetailScreen.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI
import SharedModels

struct LocationDetailScreen: View {

    // MARK: - ViewModel
    @StateObject var viewModel: LocationDetailViewModel

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: - Header
            HStack(alignment: .top, spacing: 16) {
                Text(viewModel.state.typeLabel)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)

                Text(viewModel.state.locationName)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)

                Spacer()
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)

            // MARK: - AQI Row
            HStack(spacing: 16) {
                Text("aqi")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)

                Text(viewModel.state.aqiValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
            }
            .padding(.top, 12)
            .padding(.horizontal, 24)

            // MARK: - Spacer
            // Pushes nickname + button to bottom
            // Matches design — large empty space
            Spacer()

            // MARK: - Nickname TextField
            TextField(
                "nickname",
                text: Binding(
                    get: { viewModel.state.nickname },
                    set: { viewModel.send(.nicknameChanged($0)) }
                )
            )
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        viewModel.state.isNicknameTooLong
                            ? Color.red
                            : Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
            .padding(.horizontal, 16)

            // MARK: - Nickname Too Long Warning
            if viewModel.state.isNicknameTooLong {
                Text("Nickname must be 20 characters or less")
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
            }

            // MARK: - V Button
            // Yellow full width button
            Button(action: {
                viewModel.send(.saveButtonTapped)
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.yellow)

                    Text("Update")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        // MARK: - Lifecycle
        .onAppear {
            viewModel.send(.onAppear)
        }
        // MARK: - Error Alert
        .alert(
            "Error",
            isPresented: Binding(
                get: { viewModel.state.errorMessage != nil },
                set: { _ in viewModel.send(.errorDismissed) }
            )
        ) {
            Button("OK") {
                viewModel.send(.errorDismissed)
            }
        } message: {
            Text(viewModel.state.errorMessage ?? "")
        }
        // MARK: - Navigation Bar
        // Single back button — left side
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)  // hide default back
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.send(.dismissButtonTapped)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview("Type A") {
    NavigationStack {
        LocationDetailScreen(
            viewModel: PreviewFactory.makeLocationDetailViewModel(
                type: .locationA
            )
        )
    }
}

#Preview("Type B — With Nickname") {
    NavigationStack {
        LocationDetailScreen(
            viewModel: PreviewFactory.makeLocationDetailViewModel(
                type: .locationB
            )
        )
    }
}
