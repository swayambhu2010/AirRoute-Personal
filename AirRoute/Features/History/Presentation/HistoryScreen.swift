//
//  HistoryScreen.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import SwiftUI

struct HistoryScreen: View {

    // MARK: - ViewModel
    @StateObject var viewModel: HistoryViewModel

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {

            // MARK: - Summary Header
            summaryHeader

            Divider()

            // MARK: - Content
            if viewModel.state.isLoading {
                loadingView
            } else if viewModel.state.bookings.isEmpty {
                emptyView
            } else {
                bookingList
            }
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
        // Fully hidden — no back button, no title
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Summary Header
    // Total Count  |  Total Price
    private var summaryHeader: some View {
        HStack(alignment: .center, spacing: 0) {

            // Total Count
            VStack(spacing: 6) {
                Text("Total Count")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text("\(viewModel.state.totalCount)")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)

            // Vertical Divider
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 1, height: 44)

            // Total Price
            VStack(spacing: 6) {
                Text("Total Price")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text(viewModel.state.formattedTotalPrice)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, 20)
        .padding(.bottom, 20)
        .padding(.horizontal, 24)
        .background(Color.white)
    }

    // MARK: - Loading View
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(.black)
            Spacer()
        }
    }

    // MARK: - Empty View
    private var emptyView: some View {
        VStack {
            Spacer()
            Text("No history for this month")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Booking List
    // Each cell = one booking
    // A location name
    // B location name
    // Tap → Screen 1 pre-filled ✅
    private var bookingList: some View {
        List(viewModel.state.bookings) { booking in
            Button {
                viewModel.send(.cellTapped(booking))
            } label: {
                historyCell(booking: booking)
            }
            .listRowInsets(
                EdgeInsets(
                    top: 16,
                    leading: 24,
                    bottom: 16,
                    trailing: 24
                )
            )
            .listRowSeparator(.visible)
            .listRowSeparatorTint(Color.gray.opacity(0.3))
        }
        .listStyle(.plain)
    }

    // MARK: - History Cell
    // A   Seoul A Location
    // B   Seoul B Location
    // Both label + name 18pt bold ✅
    @ViewBuilder
    private func historyCell(
        booking: BookingResult
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {

            // Location A
            HStack(spacing: 16) {
                Text("A")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 18, alignment: .leading)

                Text(booking.locationA.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            // Location B
            HStack(spacing: 16) {
                Text("B")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 18, alignment: .leading)

                Text(booking.locationB.displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews
#Preview("With History") {
    NavigationStack {
        HistoryScreen(
            viewModel: PreviewFactory.makeHistoryViewModel()
        )
    }
}

#Preview("Empty State") {
    NavigationStack {
        HistoryScreen(
            viewModel: PreviewFactory.makeHistoryViewModel()
        )
    }
}
