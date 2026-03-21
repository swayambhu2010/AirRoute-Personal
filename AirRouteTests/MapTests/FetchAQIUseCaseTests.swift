//
//  FetchAQIUseCaseTests.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import XCTest
@testable import AirRoute

final class FetchAQIUseCaseTests: XCTestCase {

    // MARK: - Properties
    private var sut: FetchAQIUseCase!
    private var mockRepository: MockLocationRepository!

    // MARK: - Setup
    override func setUp() {
        mockRepository = MockLocationRepository()
        sut = FetchAQIUseCase(repository: mockRepository)
    }

    // MARK: - Teardown
    override func tearDown() {
        sut = nil
        mockRepository = nil
    }

    // MARK: - Execute

    func test_execute_callsRepository_fetchLiveAQI() async throws {
        // When
        _ = try await sut.execute(
            latitude: 37.5642,
            longitude: 127.0016
        )

        // Then — delegates to repository ✅
        XCTAssertEqual(mockRepository.fetchLiveAQICallCount, 1)
    }

    func test_execute_passesCorrectLatitude_toRepository() async throws {
        // When
        _ = try await sut.execute(
            latitude: 37.5642,
            longitude: 127.0016
        )

        // Then ✅
        XCTAssertEqual(
            mockRepository.fetchLiveAQILastLatitude ?? 37.3423,
            37.5642,
            accuracy: 0.0001
        )
    }

    func test_execute_passesCorrectLongitude_toRepository() async throws {
        // When
        _ = try await sut.execute(
            latitude: 37.5642,
            longitude: 127.0016
        )

        // Then ✅
        XCTAssertEqual(
            mockRepository.fetchLiveAQILastLongitude ?? 122.3456,
            127.0016,
            accuracy: 0.0001
        )
    }

    func test_execute_returnsAQI_fromRepository() async throws {
        // Given
        mockRepository.fetchLiveAQIResult = .success(88)

        // When
        let aqi = try await sut.execute(
            latitude: 37.5642,
            longitude: 127.0016
        )

        // Then — no transformation, pure delegation ✅
        XCTAssertEqual(aqi, 88)
    }

    func test_execute_returnsZeroAQI_edgeCase() async throws {
        // Given
        mockRepository.fetchLiveAQIResult = .success(0)

        // When
        let aqi = try await sut.execute(
            latitude: 37.5642,
            longitude: 127.0016
        )

        // Then ✅
        XCTAssertEqual(aqi, 0)
    }

    func test_execute_returnsMaxAQI_edgeCase() async throws {
        // Given — AQI scale max = 500
        mockRepository.fetchLiveAQIResult = .success(500)

        // When
        let aqi = try await sut.execute(
            latitude: 37.5642,
            longitude: 127.0016
        )

        // Then ✅
        XCTAssertEqual(aqi, 500)
    }

    func test_execute_throwsError_whenRepositoryFails() async throws {
        // Given
        mockRepository.fetchLiveAQIResult = .failure(
            NetworkError.invalidResponse
        )

        // When / Then — error propagates ✅
        do {
            _ = try await sut.execute(
                latitude: 37.5642,
                longitude: 127.0016
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_execute_neverCachesResult_alwaysCallsRepository() async throws {
        // AQI is always live — two calls = two repository calls ✅
        mockRepository.fetchLiveAQIResult = .success(42)

        _ = try await sut.execute(latitude: 37.5642, longitude: 127.0016)
        _ = try await sut.execute(latitude: 37.5642, longitude: 127.0016)

        // Then — no caching shortcut ✅
        XCTAssertEqual(mockRepository.fetchLiveAQICallCount, 2)
    }

    func test_execute_doesNotCallAnyOtherRepositoryMethod() async throws {
        // When
        _ = try? await sut.execute(
            latitude: 37.5642,
            longitude: 127.0016
        )

        // Then — only fetchLiveAQI called ✅
        XCTAssertEqual(mockRepository.fetchLocationInfoCallCount, 0)
        XCTAssertEqual(mockRepository.fetchCachedLocationCallCount, 0)
        XCTAssertEqual(mockRepository.fetchAllCachedLocationsCallCount, 0)
        XCTAssertEqual(mockRepository.updateNicknameCallCount, 0)
        XCTAssertEqual(mockRepository.removeCachedLocationCallCount, 0)
    }
}
