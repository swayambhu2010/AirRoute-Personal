//
//  SavedLocationScreen.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI
import SharedModels

struct SavedLocationsScreen: View {

    // MARK: - ViewModel
    @StateObject var viewModel: SavedLocationsViewModel

    // MARK: - Init
    init(viewModel: SavedLocationsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {

            if viewModel.state.isEmpty {

                // MARK: - Empty State
                Spacer()
                Text("No saved locations")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                Spacer()

            } else {

                // MARK: - Grouped List
                // Each group = 2 locations
                // A + B per group
                // Separator between groups only ✅
                List {
                    ForEach(
                        Array(
                            viewModel.state.pairedGroups
                                .enumerated()
                        ),
                        id: \.offset
                    ) { _, group in
                        groupCell(group: group)
                            .listRowInsets(
                                EdgeInsets(
                                    top: 14,
                                    leading: 24,
                                    bottom: 14,
                                    trailing: 24
                                )
                            )
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(
                                Color.gray.opacity(0.3)
                            )
                    }
                }
                .listStyle(.plain)
            }
        }
        // MARK: - Lifecycle
        .onAppear {
            viewModel.send(.onAppear)
        }
        // MARK: - Navigation Bar
        // Custom back → dismissTapped
        // → Screen 1 resets ✅
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.send(.dismissTapped)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(
                            size: 16,
                            weight: .semibold
                        ))
                        .foregroundColor(.black)
                }
            }
        }
    }

    // MARK: - Group Cell
    // One cell = one group of 2 locations
    // A   location name   ← first in group
    // B   location name   ← second in group
    // Separator below entire group ✅
    @ViewBuilder
    private func groupCell(
        group: [LocationPoint]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(
                Array(group.enumerated()),
                id: \.offset
            ) { index, location in
                Button {
                    viewModel.send(
                        .locationTapped(location)
                    )
                } label: {
                    locationRow(
                        label: index == 0 ? "A" : "B",
                        location: location
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Location Row
    // A   Home            ← label + displayName bold
    //     Gangnam-gu      ← gray subname if nickname set
    @ViewBuilder
    private func locationRow(
        label: String,
        location: LocationPoint
    ) -> some View {
        HStack(alignment: .top, spacing: 16) {

            // A or B marker
            Text(label)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 16, alignment: .leading)

            // Name block
            VStack(alignment: .leading, spacing: 3) {

                // Primary — nickname or location name
                Text(location.displayName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)

                // Secondary — actual name if nickname set
                if let nickname = location.nickname,
                   !nickname.isEmpty {
                    Text(location.name)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }

            Spacer()
        }
    }
}

// MARK: - Previews
#Preview("Selecting For A") {
    NavigationStack {
        SavedLocationsScreen(
            viewModel: PreviewFactory.makeSavedLocationsViewModel(
                selectingFor: .locationA
            )
        )
    }
}

#Preview("Selecting For B") {
    NavigationStack {
        SavedLocationsScreen(
            viewModel: PreviewFactory.makeSavedLocationsViewModel(
                selectingFor: .locationB
            )
        )
    }
}
