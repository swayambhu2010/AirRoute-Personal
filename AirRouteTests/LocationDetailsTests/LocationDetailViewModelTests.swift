//
//  LocationDetailViewModelTests.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import XCTest
@testable import AirRoute

@MainActor
final class LocationDetailViewModelTests: XCTestCase {

    // MARK: - Properties
    private var sut: LocationDetailViewModel!
    private var mockFetchCachedLocation: MockFetchCachedLocationUseCase!
    private var mockUpdateNickname: MockUpdateNicknameUseCase!
    private var savedLocation: LocationPoint?
    private var didDismiss: Bool = false

    // MARK: - Shared Test Error
    private let testError = NSError(
        domain: "AirRouteTests",
        code: 1001,
        userInfo: [NSLocalizedDescriptionKey: "Save failed"]
    )

    // MARK: - Setup
    override func setUp() {
        mockFetchCachedLocation = MockFetchCachedLocationUseCase()
        mockUpdateNickname = MockUpdateNicknameUseCase()
        makeSUT()
    }

    // MARK: - Teardown
    override func tearDown() {
        sut = nil
        mockFetchCachedLocation = nil
        mockUpdateNickname = nil
        savedLocation = nil
        didDismiss = false
    }

    // Cache loads latest location on appear
    // AQI + nickname both refreshed ✅
    func test_onAppear_cacheHit_updatesLocationAndPrefillsNickname() {
        // Given
        mockFetchCachedLocation.result = makeLocation(
            name: "Gangnam",
            aqi: 75,
            nickname: "Home"
        )

        // When
        sut.send(.onAppear)

        // Then
        XCTAssertEqual(sut.state.location?.aqi, 75)
        XCTAssertEqual(sut.state.nickname, "Home")
        XCTAssertTrue(sut.state.isSaveEnabled)
    }

    // Cache MUST NOT overwrite what user is typing
    // guard: if state.nickname.isEmpty { pre-fill } ✅
    func test_onAppear_doesNotOverwriteNickname_whenUserIsEditing() {
        // Given — user already typing
        sut.send(.nicknameChanged("My Name"))
        mockFetchCachedLocation.result = makeLocation(
            name: "Gangnam",
            nickname: "Cache Name"
        )

        // When
        sut.send(.onAppear)

        // Then — user's input preserved ✅
        XCTAssertEqual(sut.state.nickname, "My Name")
    }

    // Save button disabled for empty / whitespace
    // Prevents empty nickname reaching the cache ✅
    func test_nicknameChanged_isSaveEnabled_reflects_validity() {
        // Empty → disabled
        sut.send(.nicknameChanged(""))
        XCTAssertFalse(sut.state.isSaveEnabled)

        // Whitespace only → disabled
        sut.send(.nicknameChanged("   "))
        XCTAssertFalse(sut.state.isSaveEnabled)

        // Valid → enabled
        sut.send(.nicknameChanged("Home"))
        XCTAssertTrue(sut.state.isSaveEnabled)
    }

    // Boundary: exactly 20 chars → enabled
    //           exactly 21 chars → disabled
    // Most common off-by-one bug ✅
    func test_nicknameChanged_boundary_20and21Chars() {
        // AT boundary — valid ✅
        sut.send(.nicknameChanged(
            String(repeating: "a", count: 20)
        ))
        XCTAssertTrue(sut.state.isSaveEnabled)

        // ONE over boundary — invalid ✅
        sut.send(.nicknameChanged(
            String(repeating: "a", count: 21)
        ))
        XCTAssertFalse(sut.state.isSaveEnabled)
    }

    // Full success path:
    // save → updates local copy → fires onNicknameSaved → fires onDismiss
    func test_saveButtonTapped_success_fullPath() {
        // Given
        sut.send(.nicknameChanged("Home"))

        // When
        sut.send(.saveButtonTapped)

        // Then — all three outcomes ✅
        XCTAssertEqual(sut.state.location?.nickname, "Home")
        XCTAssertEqual(savedLocation?.nickname, "Home")
        XCTAssertTrue(didDismiss)
    }

    // Full failure path:
    // save fails → error shown → no callback → no dismiss
    func test_saveButtonTapped_failure_fullPath() {
        // Given — ⚠️ must set error BEFORE save
        mockUpdateNickname.errorToThrow = testError
        sut.send(.nicknameChanged("Home"))

        // When
        sut.send(.saveButtonTapped)

        // Then — stays on screen ✅
        XCTAssertEqual(
            sut.state.errorMessage,
            testError.localizedDescription
        )
        XCTAssertNil(savedLocation)
        XCTAssertFalse(didDismiss)
        XCTAssertNil(sut.state.location?.nickname)
    }

    // After failure → errorDismissed → nickname preserved
    // so user can retry without retyping ✅
    func test_errorDismissed_clearsError_preservesNickname_forRetry() {
        // Given — save failed
        mockUpdateNickname.errorToThrow = testError
        sut.send(.nicknameChanged("Home"))
        sut.send(.saveButtonTapped)
        XCTAssertNotNil(sut.state.errorMessage)

        // When
        sut.send(.errorDismissed)

        // Then — error gone, nickname still there ✅
        XCTAssertNil(sut.state.errorMessage)
        XCTAssertEqual(sut.state.nickname, "Home")
    }

    // dismiss MUST NOT save
    // user tapping back should never write to cache ✅
    func test_dismissButtonTapped_doesNotSave_andFiresDismiss() {
        // Given
        sut.send(.nicknameChanged("Home"))

        // When
        sut.send(.dismissButtonTapped)

        // Then — no save, just navigate back ✅
        XCTAssertEqual(mockUpdateNickname.callCount, 0)
        XCTAssertNil(savedLocation)
        XCTAssertTrue(didDismiss)
    }

    // Full retry flow:
    // fail → dismiss error → retry → succeed ✅
    func test_fullFlow_fail_retry_success() {
        // Step 1 — type nickname
        sut.send(.nicknameChanged("Home"))

        // Step 2 — first save fails
        mockUpdateNickname.errorToThrow = testError
        sut.send(.saveButtonTapped)
        XCTAssertNotNil(sut.state.errorMessage)
        XCTAssertFalse(didDismiss)

        // Step 3 — dismiss error
        sut.send(.errorDismissed)
        XCTAssertNil(sut.state.errorMessage)
        XCTAssertEqual(sut.state.nickname, "Home")

        // Step 4 — retry succeeds
        mockUpdateNickname.errorToThrow = nil
        sut.send(.saveButtonTapped)

        // Then ✅
        XCTAssertEqual(savedLocation?.nickname, "Home")
        XCTAssertTrue(didDismiss)
    }

    // MARK: - Private Helpers

    private func makeSUT(
        name: String = "Gangnam",
        nickname: String? = nil,
        locationType: LocationType = .locationA
    ) {
        sut = LocationDetailViewModel(
            location: makeLocation(name: name, nickname: nickname),
            locationType: locationType,
            fetchCachedLocationUseCase: mockFetchCachedLocation,
            updateNicknameUseCase: mockUpdateNickname,
            onNicknameSaved: { [weak self] location in
                self?.savedLocation = location
            },
            onDismiss: { [weak self] in
                self?.didDismiss = true
            }
        )
    }

    private func makeLocation(
        name: String,
        latitude: Double = 37.5642,
        longitude: Double = 127.0016,
        aqi: Int = 30,
        nickname: String? = nil
    ) -> LocationPoint {
        LocationPoint(
            latitude: latitude,
            longitude: longitude,
            aqi: aqi,
            name: name,
            nickname: nickname
        )
    }
}
