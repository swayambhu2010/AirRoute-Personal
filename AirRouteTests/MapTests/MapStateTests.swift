//
//  MapStateTests.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import XCTest
import CoreLocation
@testable import AirRoute

final class MapStateTests: XCTestCase {

    // MARK: - Default State

    func test_defaultState_mapCenterIsNil() {
        let state = MapState()
        XCTAssertNil(state.mapCenter)
    }

    func test_defaultState_currentGPSLocationIsNil() {
        let state = MapState()
        XCTAssertNil(state.currentGPSLocation)
    }

    func test_defaultState_hasReceivedInitialLocationIsFalse() {
        let state = MapState()
        XCTAssertFalse(state.hasReceivedInitialLocation)
    }

    func test_defaultState_isDraggingIsFalse() {
        let state = MapState()
        XCTAssertFalse(state.isDragging)
    }

    func test_defaultState_locationAIsNil() {
        let state = MapState()
        XCTAssertNil(state.locationA)
    }

    func test_defaultState_locationBIsNil() {
        let state = MapState()
        XCTAssertNil(state.locationB)
    }

    func test_defaultState_currentAQIIsZero() {
        let state = MapState()
        XCTAssertEqual(state.currentAQI, 0)
    }

    func test_defaultState_buttonStateIsSetA() {
        let state = MapState()
        XCTAssertEqual(state.buttonState, .setA)
    }

    func test_defaultState_isLoadingIsFalse() {
        let state = MapState()
        XCTAssertFalse(state.isLoading)
    }

    func test_defaultState_errorMessageIsNil() {
        let state = MapState()
        XCTAssertNil(state.errorMessage)
    }

    // MARK: - safeMapCenter
    // Priority: mapCenter → currentGPSLocation → Seoul fallback

    func test_safeMapCenter_returnsMapCenter_whenSet() {
        // Given
        var state = MapState()
        let coordinate = CLLocationCoordinate2D(
            latitude: 37.5642,
            longitude: 127.0016
        )
        state.mapCenter = coordinate

        // Then
        XCTAssertEqual(
            state.safeMapCenter.latitude,
            coordinate.latitude,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            state.safeMapCenter.longitude,
            coordinate.longitude,
            accuracy: 0.0001
        )
    }

    func test_safeMapCenter_returnsGPSLocation_whenMapCenterIsNil() {
        // Given
        var state = MapState()
        state.mapCenter = nil
        state.currentGPSLocation = CLLocationCoordinate2D(
            latitude: 1.3521,
            longitude: 103.8198
        )

        // Then — falls back to GPS ✅
        XCTAssertEqual(
            state.safeMapCenter.latitude,
            1.3521,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            state.safeMapCenter.longitude,
            103.8198,
            accuracy: 0.0001
        )
    }

    func test_safeMapCenter_returnsSeoulFallback_whenBothNil() {
        // Given
        let state = MapState()
        // mapCenter = nil, currentGPSLocation = nil

        // Then — Seoul hardcoded fallback ✅
        XCTAssertEqual(
            state.safeMapCenter.latitude,
            37.5642,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            state.safeMapCenter.longitude,
            127.0016,
            accuracy: 0.0001
        )
    }

    func test_safeMapCenter_prefersMapCenter_overGPS() {
        // Given — both set
        var state = MapState()
        state.mapCenter = CLLocationCoordinate2D(
            latitude: 37.5642,
            longitude: 127.0016
        )
        state.currentGPSLocation = CLLocationCoordinate2D(
            latitude: 1.3521,
            longitude: 103.8198
        )

        // Then — mapCenter wins ✅
        XCTAssertEqual(
            state.safeMapCenter.latitude,
            37.5642,
            accuracy: 0.0001
        )
    }

    func test_safeMapCenter_prefersGPS_overSeoulFallback() {
        // Given — only GPS set
        var state = MapState()
        state.mapCenter = nil
        state.currentGPSLocation = CLLocationCoordinate2D(
            latitude: 1.3521,
            longitude: 103.8198
        )

        // Then — GPS wins over Seoul fallback ✅
        XCTAssertNotEqual(
            state.safeMapCenter.latitude,
            37.5642,
            accuracy: 0.0001
        )
        XCTAssertEqual(
            state.safeMapCenter.latitude,
            1.3521,
            accuracy: 0.0001
        )
    }

    // MARK: - buttonTitle

    func test_buttonTitle_isSetA_forSetAState() {
        var state = MapState()
        state.buttonState = .setA
        XCTAssertEqual(state.buttonTitle, "Set A")
    }

    func test_buttonTitle_isSetB_forSetBState() {
        var state = MapState()
        state.buttonState = .setB
        XCTAssertEqual(state.buttonTitle, "Set B")
    }

    func test_buttonTitle_isBook_forBookState() {
        var state = MapState()
        state.buttonState = .book
        XCTAssertEqual(state.buttonTitle, "Book")
    }

    // MARK: - aLabelText

    func test_aLabelText_isA_whenLocationAIsNil() {
        let state = MapState()
        XCTAssertEqual(state.aLabelText, "A")
    }

    func test_aLabelText_showsName_whenNoNickname() {
        var state = MapState()
        state.locationA = makeLocation(name: "Gangnam", nickname: nil)
        XCTAssertEqual(state.aLabelText, "Gangnam")
    }

    func test_aLabelText_showsNickname_whenNicknameSet() {
        var state = MapState()
        state.locationA = makeLocation(name: "Gangnam", nickname: "Home")
        XCTAssertEqual(state.aLabelText, "Home")
    }

    func test_aLabelText_showsName_whenNicknameIsEmpty() {
        var state = MapState()
        state.locationA = makeLocation(name: "Gangnam", nickname: "")
        // Empty nickname → fall back to name ✅
        XCTAssertEqual(state.aLabelText, "Gangnam")
    }

    // MARK: - bLabelText

    func test_bLabelText_isB_whenLocationBIsNil() {
        let state = MapState()
        XCTAssertEqual(state.bLabelText, "B")
    }

    func test_bLabelText_showsName_whenNoNickname() {
        var state = MapState()
        state.locationB = makeLocation(name: "Itaewon", nickname: nil)
        XCTAssertEqual(state.bLabelText, "Itaewon")
    }

    func test_bLabelText_showsNickname_whenNicknameSet() {
        var state = MapState()
        state.locationB = makeLocation(name: "Itaewon", nickname: "Work")
        XCTAssertEqual(state.bLabelText, "Work")
    }

    func test_bLabelText_showsName_whenNicknameIsEmpty() {
        var state = MapState()
        state.locationB = makeLocation(name: "Itaewon", nickname: "")
        XCTAssertEqual(state.bLabelText, "Itaewon")
    }

    // MARK: - isALabelEmpty

    func test_isALabelEmpty_isTrue_whenLocationAIsNil() {
        let state = MapState()
        XCTAssertTrue(state.isALabelEmpty)
    }

    func test_isALabelEmpty_isFalse_whenLocationAIsSet() {
        var state = MapState()
        state.locationA = makeLocation(name: "Seoul")
        XCTAssertFalse(state.isALabelEmpty)
    }

    // MARK: - isBLabelEmpty

    func test_isBLabelEmpty_isTrue_whenLocationBIsNil() {
        let state = MapState()
        XCTAssertTrue(state.isBLabelEmpty)
    }

    func test_isBLabelEmpty_isFalse_whenLocationBIsSet() {
        var state = MapState()
        state.locationB = makeLocation(name: "Busan")
        XCTAssertFalse(state.isBLabelEmpty)
    }

    // MARK: - Mutation

    func test_setMapCenter_updatesCorrectly() {
        var state = MapState()
        let coordinate = CLLocationCoordinate2D(
            latitude: 37.5642,
            longitude: 127.0016
        )
        state.mapCenter = coordinate
        XCTAssertEqual(
            state.mapCenter!.latitude,
            37.5642,
            accuracy: 0.0001
        )
    }

    func test_setIsDragging_true() {
        var state = MapState()
        state.isDragging = true
        XCTAssertTrue(state.isDragging)
    }

    func test_setIsDragging_false() {
        var state = MapState()
        state.isDragging = true
        state.isDragging = false
        XCTAssertFalse(state.isDragging)
    }

    func test_setCurrentAQI_updatesValue() {
        var state = MapState()
        state.currentAQI = 75
        XCTAssertEqual(state.currentAQI, 75)
    }

    func test_setErrorMessage_updatesValue() {
        var state = MapState()
        state.errorMessage = "Something went wrong"
        XCTAssertEqual(state.errorMessage, "Something went wrong")
    }

    func test_clearErrorMessage_setsNil() {
        var state = MapState()
        state.errorMessage = "Error"
        state.errorMessage = nil
        XCTAssertNil(state.errorMessage)
    }

    // MARK: - Helpers
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
