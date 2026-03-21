//
//  LocationDetailsViewModel.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import Foundation
import Combine

@MainActor
final class LocationDetailViewModel: ObservableObject {
    
    // MARK: - State
    @Published var state = LocationDetailState()
    
    // MARK: - Dependencies
    private let fetchCachedLocationUseCase: FetchCachedLocationUseCaseProtocol
    private let updateNicknameUseCase: UpdateNicknameUseCaseProtocol
    
    // MARK: - Navigation Callbacks
    private let onDismiss: () -> Void
    
    // Called BEFORE onDismiss
    // Passes updated LocationPoint back to AppRouter
    // AppRouter forwards to MapViewModel
    private let onNicknameSaved: (LocationPoint) -> Void
    
    // MARK: - Init
    init(
        location: LocationPoint,
        locationType: LocationType,
        fetchCachedLocationUseCase: FetchCachedLocationUseCaseProtocol,
        updateNicknameUseCase: UpdateNicknameUseCaseProtocol,
        onNicknameSaved: @escaping (LocationPoint) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.fetchCachedLocationUseCase = fetchCachedLocationUseCase
        self.updateNicknameUseCase = updateNicknameUseCase
        self.onNicknameSaved = onNicknameSaved
        self.onDismiss = onDismiss
        self.state.location = location
        self.state.locationType = locationType
        // Pre-fill nickname if already set
        self.state.updateNickname(location.nickname ?? "")
    }
    
    // MARK: - Send
    func send(_ action: LocationDetailAction) {
        switch action {
            
        case .onAppear:
            // Load latest from cache
            // Nickname may have been updated
            loadFromCache()
            
        case .nicknameChanged(let text):
            // ← Single line, no inline logic
            // All validation owned by State
            state.updateNickname(text)
            
        case .saveButtonTapped:
            saveNickname()
            
        case .dismissButtonTapped:
            onDismiss()
            
        case .errorDismissed:
            state.errorMessage = nil
        }
    }
    
    // MARK: - Private
    
    private func loadFromCache() {
        guard let location = state.location else { return }
        // Load from cache — gets latest AQI + nickname
        if let cached = fetchCachedLocationUseCase.execute(
            latitude: location.latitude,
            longitude: location.longitude
        ) {
            state.location = cached
            // Only pre-fill nickname if not
            // already being edited
            if state.nickname.isEmpty {
                state.updateNickname(cached.nickname ?? "")
            }
        }
    }
    
    private func saveNickname() {
        guard var location = state.location else { return }
        do {
            try updateNicknameUseCase.execute(
                nickname: state.nickname,
                for: location
            )
            // Update local copy with new nickname
            location.nickname = state.nickname
            state.location = location
            // Notify AppRouter → MapViewModel
            // Label on Screen 1 updates immediately
            onNicknameSaved(location)   // ← NEW
            onDismiss()
        } catch {
            state.errorMessage = error.localizedDescription
        }
    }
}

