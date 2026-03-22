//
//  HistoryScreen.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import ComposableArchitecture
import SwiftUI

struct HistoryScreen: View {

    // @Bindable replaces @StateObject
    // store.x replaces viewModel.state.x
    @Perception.Bindable var store: StoreOf<HistoryFeature>

    var body: some View {
        VStack(spacing: 0) {
            summaryHeader
            if store.isLoading {
                loadingView
            } else if store.bookings.isEmpty {
                emptyView
            } else {
                bookingList
            }
        }
        .onAppear {
            store.send(.onAppear)       // identical to viewModel.send(.onAppear)
        }
        .alert("Error",
            isPresented: Binding(
                get:  { store.errorMessage != nil },
                set:  { _ in store.send(.errorDismissed) }
            )
        ) {
            Button("OK") { store.send(.errorDismissed) }
        } message: {
            Text(store.errorMessage ?? "")
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var summaryHeader: some View {
        HStack {
            VStack(spacing: 6) {
                Text("Total Count").font(.system(size: 14)).foregroundColor(.secondary)
                Text("\(store.totalCount)").font(.system(size: 28, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            Rectangle().fill(Color.gray.opacity(0.3)).frame(width: 1, height: 44)
            VStack(spacing: 6) {
                Text("Total Price").font(.system(size: 14)).foregroundColor(.secondary)
                Text(store.formattedTotalPrice)
                    .font(.system(size: 28, weight: .bold))
                    .minimumScaleFactor(0.6).lineLimit(1)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20).padding(.horizontal, 24)
    }

    private var bookingList: some View {
        List(store.bookings) { booking in
            Button {
                store.send(.cellTapped(booking))  // identical to viewModel.send()
            } label: {
                historyCell(booking: booking)
            }
            .listRowInsets(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func historyCell(booking: BookingResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                Text("A").font(.system(size: 18, weight: .bold))
                Text(booking.locationA.displayName)
                    .font(.system(size: 18, weight: .bold)).lineLimit(1)
            }
            HStack(spacing: 16) {
                Text("B").font(.system(size: 18, weight: .bold))
                Text(booking.locationB.displayName)
                    .font(.system(size: 18, weight: .bold)).lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var loadingView: some View {
        VStack { Spacer(); ProgressView().tint(.black); Spacer() }
    }

    private var emptyView: some View {
        VStack { Spacer(); Text("No history for this month").foregroundColor(.secondary); Spacer() }
    }
}
