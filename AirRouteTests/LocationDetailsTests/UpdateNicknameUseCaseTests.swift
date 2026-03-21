//
//  UpdateNicknameUseCaseTests.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import XCTest
@testable import AirRoute

final class UpdateNicknameUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: UpdateNicknameUseCase!
    private var mockRepository: MockLocationRepository!

    // MARK: - Setup
    override func setUp() {
        mockRepository = MockLocationRepository()
        sut = UpdateNicknameUseCase(repository: mockRepository)
    }

    // MARK: - Teardown
    override func tearDown() {
        sut = nil
        mockRepository = nil
    }

    // MARK: - Rule 1: Max 20 Characters

    func test_execute_succeeds_forNicknameUnder20Chars() throws {
        // When
        try sut.execute(nickname: "Home", for: makeLocation())

        // Then ✅
        XCTAssertEqual(mockRepository.updateNicknameCallCount, 1)
    }

    func test_execute_succeeds_atBoundary_exactly20Chars() throws {
        // Exactly at limit — valid ✅
        let nickname = String(repeating: "a", count: 20)

        // When / Then
        XCTAssertNoThrow(
            try sut.execute(nickname: nickname, for: makeLocation())
        )
        XCTAssertEqual(mockRepository.updateNicknameCallCount, 1)
    }

    func test_execute_throws_nicknameTooLong_for21Chars() {
        // One over limit ✅
        let nickname = String(repeating: "a", count: 21)

        // When / Then
        XCTAssertThrowsError(
            try sut.execute(nickname: nickname, for: makeLocation())
        ) { error in
            XCTAssertEqual(
                error as? LocationError,
                LocationError.nicknameTooLong
            )
        }
    }

    func test_execute_doesNotCallRepository_whenNicknameTooLong() {
        // Given
        let nickname = String(repeating: "a", count: 21)

        // When
        try? sut.execute(nickname: nickname, for: makeLocation())

        // Then — validation fails BEFORE repository call ✅
        XCTAssertEqual(mockRepository.updateNicknameCallCount, 0)
    }

    func test_execute_throws_nicknameTooLong_for100Chars() {
        // Given
        let nickname = String(repeating: "a", count: 100)

        // When / Then ✅
        XCTAssertThrowsError(
            try sut.execute(nickname: nickname, for: makeLocation())
        ) { error in
            XCTAssertEqual(
                error as? LocationError,
                LocationError.nicknameTooLong
            )
        }
    }

    // MARK: - Rule 2: Trimming Before Validation

    func test_execute_trimsWhitespace_beforePassingToRepository() throws {
        // When
        try sut.execute(nickname: "  Home  ", for: makeLocation())

        // Then — trimmed value passed to repository ✅
        XCTAssertEqual(mockRepository.updateNicknameLastNickname, "Home")
    }

    func test_execute_trimsLeadingWhitespace() throws {
        // When
        try sut.execute(nickname: "   Home", for: makeLocation())

        // Then ✅
        XCTAssertEqual(mockRepository.updateNicknameLastNickname, "Home")
    }

    func test_execute_trimsTrailingWhitespace() throws {
        // When
        try sut.execute(nickname: "Home   ", for: makeLocation())

        // Then ✅
        XCTAssertEqual(mockRepository.updateNicknameLastNickname, "Home")
    }

    func test_execute_trimsNewlines() throws {
        // When
        try sut.execute(nickname: "\nHome\n", for: makeLocation())

        // Then ✅
        XCTAssertEqual(mockRepository.updateNicknameLastNickname, "Home")
    }

    func test_execute_validatesAfterTrimming_trimmedValueIs20Chars_valid() throws {
        // "  " + 20 a's = 22 raw chars
        // After trim = 20 chars → valid ✅
        let nickname = "  " + String(repeating: "a", count: 20)

        XCTAssertNoThrow(
            try sut.execute(nickname: nickname, for: makeLocation())
        )
    }

    func test_execute_validatesAfterTrimming_trimmedValueIs21Chars_invalid() {
        // "  " + 21 a's = 23 raw chars
        // After trim = 21 chars → invalid ✅
        let nickname = "  " + String(repeating: "a", count: 21)

        XCTAssertThrowsError(
            try sut.execute(nickname: nickname, for: makeLocation())
        )
    }

    // MARK: - Rule 2: Empty → Clear Nickname

    func test_execute_emptyNickname_callsRepository_withEmptyString() throws {
        // Empty string → repository sets nil ✅
        try sut.execute(nickname: "", for: makeLocation())

        XCTAssertEqual(mockRepository.updateNicknameCallCount, 1)
        XCTAssertEqual(mockRepository.updateNicknameLastNickname, "")
    }

    func test_execute_whitespaceOnly_trimsToEmpty_callsRepositoryWithEmpty() throws {
        // "   " → trimmed → "" → repository ✅
        try sut.execute(nickname: "   ", for: makeLocation())

        XCTAssertEqual(mockRepository.updateNicknameLastNickname, "")
    }

    // MARK: - Rule 3: Correct Location Passed

    func test_execute_passesCorrectLocation_toRepository() throws {
        // Given
        let location = makeLocation(name: "Gangnam")

        // When
        try sut.execute(nickname: "Home", for: location)

        // Then ✅
        XCTAssertEqual(
            mockRepository.updateNicknameLastLocation?.name,
            "Gangnam"
        )
    }

    func test_execute_passesCorrectCoordinates_toRepository() throws {
        // Given
        let location = makeLocation(
            latitude: 37.5642,
            longitude: 127.0016
        )

        // When
        try sut.execute(nickname: "Home", for: location)

        // Then ✅
        XCTAssertEqual(
            mockRepository.updateNicknameLastLocation?.latitude ?? 37.2354,
            37.5642,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            mockRepository.updateNicknameLastLocation?.longitude ?? 122.3421,
            127.0016,
            accuracy: 0.0001
        )
    }

    // MARK: - Repository Error Propagation

    func test_execute_throwsError_whenRepositoryFails() {
        // Given
        mockRepository.updateNicknameErrorToThrow = NSError(
            domain: "AirRouteTests",
            code: 999,
            userInfo: [NSLocalizedDescriptionKey: "Cache write failed"]
        )

        // When / Then — repository error propagates ✅
        XCTAssertThrowsError(
            try sut.execute(nickname: "Home", for: makeLocation())
        ) { error in
            XCTAssertEqual((error as NSError).code, 999)
        }
    }

    func test_execute_doesNotThrow_whenRepositorySucceeds() {
        // Given
        mockRepository.updateNicknameErrorToThrow = nil

        // When / Then ✅
        XCTAssertNoThrow(
            try sut.execute(nickname: "Home", for: makeLocation())
        )
    }

    func test_execute_doesNotCallAnyOtherRepositoryMethod() throws {
        // UpdateNickname MUST only write, not read ✅
        try sut.execute(nickname: "Home", for: makeLocation())

        // Then ✅
        XCTAssertEqual(mockRepository.fetchLocationInfoCallCount, 0)
        XCTAssertEqual(mockRepository.fetchLiveAQICallCount, 0)
        XCTAssertEqual(mockRepository.fetchCachedLocationCallCount, 0)
        XCTAssertEqual(mockRepository.fetchAllCachedLocationsCallCount, 0)
        XCTAssertEqual(mockRepository.removeCachedLocationCallCount, 0)
    }

    // MARK: - Private Helpers

    private func makeLocation(
        name: String = "Gangnam",
        latitude: Double = 37.5642,
        longitude: Double = 127.0016,
        aqi: Int = 30
    ) -> LocationPoint {
        LocationPoint(
            latitude: latitude,
            longitude: longitude,
            aqi: aqi,
            name: name,
            nickname: nil
        )
    }
}
