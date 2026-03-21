//
//  BookingScreen.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI

struct BookingScreen: View {
    
    // MARK: - ViewModel
    @StateObject var viewModel: BookingViewModel
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            
            if viewModel.state.isLoading {
                
                // MARK: Loading
                Spacer()
                ProgressView("Booking...")
                    .tint(.black)
                Spacer()
                
            } else {
                
                // MARK: Content
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: Location A
                        locationBlock(
                            label: "A",
                            name: viewModel.state.aLocationName,
                            aqi: viewModel.state.aAQI,
                            nickname: viewModel.state.aNickname
                        )
                        
                        Divider()
                            .padding(.horizontal, 24)
                        
                        // MARK: Location B
                        locationBlock(
                            label: "B",
                            name: viewModel.state.bLocationName,
                            aqi: viewModel.state.bAQI,
                            nickname: viewModel.state.bNickname
                        )
                    }
                }
                
                Spacer()
                
                // MARK: Price Row
                // "price          $10,000.00"
                HStack {
                    Text("price")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(viewModel.state.formattedPrice)
                        .font(.system(
                            size: 18,
                            weight: .bold    // ← bold ✅
                        ))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
                
                // MARK: View History Button → Screen 4
                Button(action: {
                    viewModel.send(.goToHistoryTapped)
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.yellow)
                        Text("View History")
                            .font(.system(
                                size: 18,
                                weight: .bold
                            ))
                            .foregroundColor(.black)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        // MARK: Lifecycle
        .onAppear {
            viewModel.send(.onAppear)
        }
        // MARK: Error Alert
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
        // MARK: Navigation Bar
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
    
    // MARK: - Location Block
    @ViewBuilder
    private func locationBlock(
        label: String,
        name: String,
        aqi: Int,
        nickname: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .top, spacing: 16) {
                Text(label)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 20, alignment: .leading)
                
                Text(name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                Spacer()
            }
            .padding(.top, 24)
            .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 6) {
                infoRow(label: "aqi", value: "\(aqi)")
                
                if let nickname, !nickname.isEmpty {
                    infoRow(label: "nickname", value: nickname)
                }
            }
            // 24 outer + 20 label width + 16 spacing
            // = 60 — aligns under location name ✅
            .padding(.leading, 60)
            .padding(.top, 8)
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - Info Row
    @ViewBuilder
    private func infoRow(
        label: String,
        value: String
    ) -> some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            // Fixed width — "nickname" and "aqi"
            // values left-align consistently ✅
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
            
            Spacer()
        }
    }
}

// MARK: - Previews
#Preview("Loading") {
    NavigationStack {
        BookingScreen(
            viewModel: PreviewFactory.makeBookingViewModel()
        )
    }
}

#Preview("With Result") {
    NavigationStack {
        BookingScreen(
            viewModel: PreviewFactory.makeBookingViewModel()
        )
    }
}
