//
//  MapScreen.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI
import CoreLocation
import Combine

struct MapScreen: View {

    // MARK: - ViewModel
    @StateObject var viewModel: MapViewModel

    // MARK: - LocationManager
    @EnvironmentObject var locationManager: LocationManager

    // MARK: - Body
    var body: some View {
        ZStack {

            // MARK: ① Map Layer — full screen
            // Double guard:
            // 1. hasReceivedInitialLocation = true
            // 2. mapCenter is non-nil
            // Both must pass — no hardcoded flash ✅
            // No crash on resetState ✅
            if viewModel.state.hasReceivedInitialLocation,
               viewModel.state.mapCenter != nil {
                MapRenderView(viewModel: viewModel)
                    .ignoresSafeArea()
            } else {
                // Waiting for GPS
                // Typically resolves in < 1 second
                Color.white
                    .ignoresSafeArea()
            }

            // MARK: ② Fixed Center Pin
            // Always on top of map
            // NEVER moves — map moves UNDER it ✅
            // Lifts when user drags (isDragging = true)
            // Settles when map is idle (isDragging = false)
            PinOverlayView(
                isDragging: viewModel.state.isDragging
            )

            // MARK: ③ Bottom Panel
            VStack {
                Spacer()
                MapBottomPanelView(
                    aLabelText: viewModel.state.aLabelText,
                    bLabelText: viewModel.state.bLabelText,
                    buttonTitle: viewModel.state.buttonTitle,
                    isLoading: viewModel.state.isLoading,
                    onATapped: {
                        viewModel.send(.labelTapped(.locationA))
                    },
                    onBTapped: {
                        viewModel.send(.labelTapped(.locationB))
                    },
                    onButtonTapped: {
                        viewModel.send(.vButtonTapped)
                    }
                )
            }

            // MARK: ④ Loading Overlay
            // Transparent — doesn't block map gestures ✅
            if viewModel.state.isLoading {
                Color.black.opacity(0.1)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }

        // MARK: - Navigation Bar
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                // AQI of CURRENT pin position
                // Updates on every camera idle ✅
                AQIBadgeView(aqi: viewModel.state.currentAQI)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)

        // MARK: - Lifecycle
        .onAppear {
            viewModel.send(.onAppear)
        }

        // MARK: - GPS — One Shot
        // Waits for LocationManager first non-nil coordinate
        // Sends to ViewModel → sets permanent GPS anchor
        // Breaks immediately — never fires again ✅
        .task {
            for await coordinate in locationManager
                .$currentLocation
                .compactMap({ $0 })
                .values
            {
                viewModel.send(.initialLocationReceived(coordinate))
                break
            }
        }

        // MARK: - Error Alert
        .alert(
            "Error",
            isPresented: Binding<Bool>(
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
    }
}

// MARK: - MapRenderView
// Separated from MapScreen so GoogleMapView
// doesn't rebuild on every @Published state change
// safeMapCenter used — no force unwrap, no crash ✅
private struct MapRenderView: View {

    @ObservedObject var viewModel: MapViewModel

    var body: some View {
        GoogleMapView(
            // safeMapCenter NEVER returns nil
            // Priority: mapCenter → GPS → Seoul
            // No crash on resetState ✅
            initialCoordinate: viewModel.state.safeMapCenter,
            zoomLevel: 15.0,
            onCameraIdle: { coordinate in
                viewModel.send(.mapCameraIdle(coordinate))
            },
            onDragStarted: {
                viewModel.send(.mapDragStarted)
            }
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - PinOverlayView
// Fixed at screen center — NEVER moves
// Map slides under it ✅
//
// isDragging = true  → pin lifts   (offset -24, light shadow)
// isDragging = false → pin settles (offset -16, strong shadow)
// Spring animation matches TADA / Grab / Uber feel ✅
private struct PinOverlayView: View {

    let isDragging: Bool

    var body: some View {
        Image("pin")
            // -16 = resting (pin tip at screen center)
            // -24 = lifted while user drags
            .offset(y: isDragging ? -24 : -16)
            .animation(
                .spring(
                    response: 0.3,
                    dampingFraction: 0.6
                ),
                value: isDragging
            )
            // Shadow grows when pin lands
            // shrinks when lifted ✅
            .shadow(
                color: .black.opacity(
                    isDragging ? 0.15 : 0.3
                ),
                radius: isDragging ? 8 : 4,
                x: 0,
                y: isDragging ? 4 : 2
            )
    }
}

// MARK: - MapBottomPanelView
struct MapBottomPanelView: View {

    // MARK: - Properties
    let aLabelText: String
    let bLabelText: String
    let buttonTitle: String
    let isLoading: Bool
    let onATapped: () -> Void
    let onBTapped: () -> Void
    let onButtonTapped: () -> Void

    // MARK: - Body
    var body: some View {
        ZStack {

            // MARK: White background panel
            // Rounded top corners only
            // Flat bottom — extends under home indicator
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24
            )
            .fill(Color.white)
            .shadow(
                color: .black.opacity(0.08),
                radius: 12,
                x: 0,
                y: -4
            )

            // MARK: Content
            VStack(spacing: 0) {
                HStack(alignment: .center, spacing: 12) {

                    // MARK: A + B Labels
                    VStack(spacing: 10) {

                        // A Label
                        locationLabel(
                            text: aLabelText,
                            onTap: onATapped
                        )

                        // B Label
                        locationLabel(
                            text: bLabelText,
                            onTap: onBTapped
                        )
                    }
                    .frame(maxWidth: .infinity)

                    // MARK: V Button
                    // Tall yellow square — spans both labels
                    // Height = (56 * 2) + 10 spacing = 122
                    Button(action: onButtonTapped) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.yellow)

                            if isLoading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text(buttonTitle)
                                    .font(.system(
                                        size: 22,
                                        weight: .bold
                                    ))
                                    .foregroundStyle(.black)
                            }
                        }
                    }
                    .frame(width: 88)
                    .frame(height: 122)
                    .disabled(isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)

                // Home indicator spacer
                Spacer()
                    .frame(height: 16)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Location Label
    @ViewBuilder
    private func locationLabel(
        text: String,
        onTap: @escaping () -> Void
    ) -> some View {
        Button(action: onTap) {
            HStack {
                Text(text)
                    .font(.system(
                        size: 16,
                        weight: .semibold
                    ))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer()
            }
            .frame(height: 56)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews
#Preview {
    NavigationStack {
        MapScreen(
            viewModel: PreviewFactory.makeMapViewModel()
        )
        .environmentObject(LocationManager())
    }
}
