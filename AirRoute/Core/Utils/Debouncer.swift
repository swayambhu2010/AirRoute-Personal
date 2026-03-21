//
//  Debouncer.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation

final class Debouncer {

    // MARK: - Properties
    private let delay: TimeInterval
    private var task: Task<Void, Never>?

    // MARK: - Init
    init(delay: TimeInterval) {
        self.delay = delay
    }

    // MARK: - Debounce
    func debounce(action: @escaping () -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(
                nanoseconds: UInt64(delay * 1_000_000_000)
            )
            guard !Task.isCancelled else { return }
            await MainActor.run { action() }
        }
    }

    // MARK: - Cancel
    func cancel() {
        task?.cancel()
        task = nil
    }
}
