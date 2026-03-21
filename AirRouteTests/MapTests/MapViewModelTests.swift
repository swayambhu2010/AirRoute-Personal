//
//  MapViewModelTests.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import XCTest
import CoreLocation
@testable import AirRoute

@MainActor
final class MapViewModelTests: XCTestCase {

    // MARK: - Properties
    private var sut: MapViewModel!
    private var mockFetchLocationInfo: MockFetchLocationInfoUseCase!
    private var mockFetchAQI: MockFetchAQIUseCase!
    private var labelTappedType: LocationType?
    private var bookTappedA: LocationPoint?
    private var bookTappedB: LocationPoint?

    // MARK: - Setup
    override func setUp() {
        mockFetchLocationInfo = MockFetchLocationInfoUseCase()
        mockFetchAQI = MockFetchAQIUseCase()
        makeSUT()
    }

    // MARK: - Teardown
    override func tearDown() {
        sut = nil
        mockFetchLocationInfo = nil
        mockFetchAQI = nil
        labelTappedType = nil
        bookTappedA = nil
        bookTappedB = nil
    }

    // GPS is one-shot — second call must be ignored
    // LocationManager may publish multiple times
    // Without this guard, map jumps on second GPS event ✅
    func test_initialLocationReceived_oneShotGuard_ignoresSecondGPS() async throws {
        // Given — first GPS received
        try await receiveInitialGPS(
            latitude: 37.5642,
            longitude: 127.0016
        )
        let callCountAfterFirst = mockFetchLocationInfo.callCount

        // When — second GPS fires
        sut.send(.initialLocationReceived(
            makeCoordinate(latitude: 1.3521, longitude: 103.8198)
        ))
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then — first coordinate preserved, no extra fetch ✅
        let mapCenter = try XCTUnwrap(sut.state.mapCenter)
        XCTAssertEqual(mapCenter.latitude, 37.5642, accuracy: 0.0001)
        XCTAssertEqual(mockFetchLocationInfo.callCount, callCountAfterFirst)
    }

    // GPS anchor MUST survive resetState
    // Without this, map shows white screen after booking ✅
    func test_resetState_preservesGPSAnchor_andReturnsMapToGPS() async throws {
        // Given — GPS received, user moved map elsewhere
        try await receiveInitialGPS(
            latitude: 37.5642,
            longitude: 127.0016
        )
        sut.send(.mapCameraIdle(
            makeCoordinate(latitude: 1.3521, longitude: 103.8198)
        ))

        // When — booking complete, reset fired
        sut.send(.resetState)

        // Then — GPS anchor preserved, map back at GPS ✅
        let gps = try XCTUnwrap(sut.state.currentGPSLocation)
        XCTAssertEqual(gps.latitude, 37.5642, accuracy: 0.0001)

        let mapCenter = try XCTUnwrap(sut.state.mapCenter)
        XCTAssertEqual(mapCenter.latitude, 37.5642, accuracy: 0.0001)

        XCTAssertTrue(sut.state.hasReceivedInitialLocation)
    }

    // Full happy path: GPS → setA → setB → Book
    // Core user journey — if this breaks, app is broken ✅
    func test_fullFlow_GPS_setA_setB_book() async throws {
        // Step 1 — GPS
        try await receiveInitialGPS(
            latitude: 37.5642,
            longitude: 127.0016
        )
        XCTAssertEqual(sut.state.buttonState, .setA)

        // Step 2 — Set A
        try await setLocationA(name: "Gangnam")
        XCTAssertEqual(sut.state.locationA?.name, "Gangnam")
        XCTAssertEqual(sut.state.buttonState, .setB)

        // Step 3 — Set B
        try await setLocationB(name: "Itaewon")
        XCTAssertEqual(sut.state.locationB?.name, "Itaewon")
        XCTAssertEqual(sut.state.buttonState, .book)

        // Step 4 — Book
        sut.send(.vButtonTapped)
        XCTAssertEqual(bookTappedA?.name, "Gangnam")
        XCTAssertEqual(bookTappedB?.name, "Itaewon")
    }

    // vButtonTapped in book state MUST guard against nil A/B
    // Defensive edge case — prevents crash on corrupt state ✅
    func test_vButtonTapped_inBookState_doesNotFire_whenLocationAIsNil() {
        // Given — B set but A nil (should never happen, but guard must exist)
        sut.send(.locationSet(makeLocation(name: "B"), .locationB))

        // When
        sut.send(.vButtonTapped)

        // Then — callback NOT triggered ✅
        XCTAssertNil(bookTappedA)
        XCTAssertNil(bookTappedB)
    }

    // AQI fetch failure MUST be silent
    // AQI is non-critical — showing error for it is bad UX ✅
    func test_mapCameraIdle_aqiFetchFailed_silentlyPreservesExistingAQI() async throws {
        // Given — AQI has a value, then fetch fails
        sut.send(.aqiFetched(50))
        mockFetchAQI.result = .failure(NetworkError.invalidResponse)

        // When
        sut.send(.mapCameraIdle(
            makeCoordinate(latitude: 37.5, longitude: 127.0)
        ))
        try await Task.sleep(nanoseconds: 700_000_000)

        // Then — no error shown, existing AQI preserved ✅
        XCTAssertNil(sut.state.errorMessage)
        XCTAssertEqual(sut.state.currentAQI, 50)
    }

    // vButtonTapped fetch failure MUST show error
    // and MUST NOT advance button state ✅
    func test_vButtonTapped_fetchFailed_setsError_doesNotAdvanceButton() async throws {
        // Given
        mockFetchLocationInfo.result = .failure(
            NetworkError.invalidResponse
        )
        sut.send(.mapCameraIdle(
            makeCoordinate(latitude: 37.5642, longitude: 127.0016)
        ))

        // When
        sut.send(.vButtonTapped)
        try await Task.sleep(nanoseconds: 100_000_000)

        // Then — error shown, stays on setA ✅
        XCTAssertNotNil(sut.state.errorMessage)
        XCTAssertEqual(sut.state.buttonState, .setA)
        XCTAssertFalse(sut.state.isLoading)
    }

    // locationSelectedFromSaved MUST move map to saved coordinate
    // and set correct button state based on existing slots ✅
    func test_locationSelectedFromSaved_movesMap_andSetsCorrectButtonState() throws {
        // Given — B already set
        sut.send(.locationSet(makeLocation(name: "Work"), .locationB))

        // When — pick A from saved
        sut.send(.locationSelectedFromSaved(
            makeLocation(name: "Home", latitude: 37.111, longitude: 127.222),
            .locationA
        ))

        // Then — map moved to saved location ✅
        let mapCenter = try XCTUnwrap(sut.state.mapCenter)
        XCTAssertEqual(mapCenter.latitude, 37.111, accuracy: 0.0001)
        XCTAssertEqual(mapCenter.longitude, 127.222, accuracy: 0.0001)

        // Both slots filled → Book ✅
        XCTAssertEqual(sut.state.buttonState, .book)
    }

    // preloadFromHistory MUST fill both slots,
    // set book state, and move map to A ✅
    func test_preloadFromHistory_fillsBothSlots_movesMapToA_setsBook() throws {
        // When
        sut.send(.preloadFromHistory(
            a: makeLocation(name: "Start", latitude: 37.5, longitude: 127.0),
            b: makeLocation(name: "End")
        ))

        // Then ✅
        XCTAssertEqual(sut.state.locationA?.name, "Start")
        XCTAssertEqual(sut.state.locationB?.name, "End")
        XCTAssertEqual(sut.state.buttonState, .book)
        let mapCenter = try XCTUnwrap(sut.state.mapCenter)
        XCTAssertEqual(mapCenter.latitude, 37.5, accuracy: 0.0001)
    }

    // resetState MUST wipe A, B, button → setA
    // and clear errors ✅
    func test_resetState_wipesAllState_exceptGPS() async throws {
        // Given — full booking flow completed
        try await receiveInitialGPS(
            latitude: 37.5642,
            longitude: 127.0016
        )
        try await setLocationA(name: "Gangnam")
        try await setLocationB(name: "Itaewon")
        sut.send(.fetchFailed(NetworkError.invalidResponse))

        // When
        sut.send(.resetState)

        // Then — slate wiped ✅
        XCTAssertNil(sut.state.locationA)
        XCTAssertNil(sut.state.locationB)
        XCTAssertEqual(sut.state.buttonState, .setA)
        XCTAssertNil(sut.state.errorMessage)
        XCTAssertFalse(sut.state.isDragging)

        // GPS anchor preserved ✅
        XCTAssertNotNil(sut.state.currentGPSLocation)
    }

    // locationUpdated MUST update label text immediately
    // Nickname saved on Screen 2 → Screen 1 label reflects it ✅
    func test_locationUpdated_updatesLabelText_immediately() {
        // Given — A set with no nickname
        sut.send(.locationSet(makeLocation(name: "Gangnam"), .locationA))
        XCTAssertEqual(sut.state.aLabelText, "Gangnam")

        // When — nickname saved from Screen 2
        sut.send(.locationUpdated(
            LocationPoint(
                latitude: 37.5642,
                longitude: 127.0016,
                aqi: 30,
                name: "Gangnam",
                nickname: "Home"
            ),
            .locationA
        ))

        // Then — label shows nickname immediately ✅
        XCTAssertEqual(sut.state.locationA?.nickname, "Home")
        XCTAssertEqual(sut.state.aLabelText, "Home")
        // Button state unchanged ✅
        XCTAssertEqual(sut.state.buttonState, .setB)
    }

    // MARK: - Private Helpers

    private func makeSUT() {
        sut = MapViewModel(
            fetchLocationInfoUseCase: mockFetchLocationInfo,
            fetchAQIUseCase: mockFetchAQI,
            onLabelTapped: { [weak self] type in
                self?.labelTappedType = type
            },
            onBookTapped: { [weak self] a, b in
                self?.bookTappedA = a
                self?.bookTappedB = b
            }
        )
    }

    private func receiveInitialGPS(
        latitude: Double,
        longitude: Double
    ) async throws {
        mockFetchLocationInfo.result = .success(
            makeLocation(name: "Seoul", aqi: 30)
        )
        mockFetchAQI.result = .success(30)
        sut.send(.initialLocationReceived(
            makeCoordinate(latitude: latitude, longitude: longitude)
        ))
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    private func setLocationA(name: String) async throws {
        mockFetchLocationInfo.result = .success(makeLocation(name: name))
        sut.send(.mapCameraIdle(
            makeCoordinate(latitude: 37.5642, longitude: 127.0016)
        ))
        sut.send(.vButtonTapped)
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    private func setLocationB(name: String) async throws {
        mockFetchLocationInfo.result = .success(makeLocation(name: name))
        sut.send(.mapCameraIdle(
            makeCoordinate(latitude: 37.5700, longitude: 127.0100)
        ))
        sut.send(.vButtonTapped)
        try await Task.sleep(nanoseconds: 100_000_000)
    }

    private func makeCoordinate(
        latitude: Double,
        longitude: Double
    ) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    private func makeLocation(
        name: String,
        nickname: String? = nil,
        latitude: Double = 37.5642,
        longitude: Double = 127.0016,
        aqi: Int = 30
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
