//
//  LocationDetailStateTests.swift
//  AirRouteTests
//
//  Created by Swayambhu BANERJEE on 15/03/26.
//

import XCTest
@testable import AirRoute

final class LocationDetailStateTests: XCTestCase {

    // MARK: - Default State

    func test_defaultState_nicknameIsEmpty() {
        let state = LocationDetailState()
        XCTAssertEqual(state.nickname, "")
    }

    func test_defaultState_isNicknameTooLongIsFalse() {
        let state = LocationDetailState()
        XCTAssertFalse(state.isNicknameTooLong)
    }

    func test_defaultState_isSaveEnabledIsFalse() {
        let state = LocationDetailState()
        // Empty nickname — save disabled ✅
        XCTAssertFalse(state.isSaveEnabled)
    }

    func test_defaultState_errorMessageIsNil() {
        let state = LocationDetailState()
        XCTAssertNil(state.errorMessage)
    }

    // MARK: - isNicknameTooLong
    // Boundary: max 20 characters (per requirements)

    func test_isNicknameTooLong_false_for1Char() {
        var state = LocationDetailState()
        state.updateNickname("A")
        XCTAssertFalse(state.isNicknameTooLong)
    }

    func test_isNicknameTooLong_false_for10Chars() {
        var state = LocationDetailState()
        state.updateNickname("HomeSweet1")   // 10 chars
        XCTAssertFalse(state.isNicknameTooLong)
    }

    func test_isNicknameTooLong_false_for19Chars() {
        var state = LocationDetailState()
        state.updateNickname(String(repeating: "a", count: 19))
        XCTAssertFalse(state.isNicknameTooLong)
    }

    func test_isNicknameTooLong_false_for20Chars_atBoundary() {
        // Exactly 20 — AT boundary — NOT too long ✅
        var state = LocationDetailState()
        state.updateNickname(String(repeating: "a", count: 20))
        XCTAssertFalse(state.isNicknameTooLong)
    }

    func test_isNicknameTooLong_true_for21Chars_overBoundary() {
        // 21 — ONE over boundary — IS too long ✅
        var state = LocationDetailState()
        state.updateNickname(String(repeating: "a", count: 21))
        XCTAssertTrue(state.isNicknameTooLong)
    }

    func test_isNicknameTooLong_true_for25Chars() {
        var state = LocationDetailState()
        state.updateNickname(String(repeating: "a", count: 25))
        XCTAssertTrue(state.isNicknameTooLong)
    }

    // MARK: - isSaveEnabled
    // Conditions: not empty, not whitespace only, not too long

    func test_isSaveEnabled_false_whenEmpty() {
        var state = LocationDetailState()
        state.updateNickname("")
        XCTAssertFalse(state.isSaveEnabled)
    }

    func test_isSaveEnabled_false_whenSingleSpace() {
        var state = LocationDetailState()
        state.updateNickname(" ")
        XCTAssertFalse(state.isSaveEnabled)
    }

    func test_isSaveEnabled_false_whenMultipleSpaces() {
        var state = LocationDetailState()
        state.updateNickname("   ")
        XCTAssertFalse(state.isSaveEnabled)
    }

    func test_isSaveEnabled_false_whenTabsAndSpaces() {
        var state = LocationDetailState()
        state.updateNickname("  \t  ")
        XCTAssertFalse(state.isSaveEnabled)
    }

    func test_isSaveEnabled_true_forValidShortName() {
        var state = LocationDetailState()
        state.updateNickname("Home")
        XCTAssertTrue(state.isSaveEnabled)
    }

    func test_isSaveEnabled_true_forNameWithSpacesInside() {
        // Spaces inside the string — valid ✅
        var state = LocationDetailState()
        state.updateNickname("Home Sweet Home")
        XCTAssertTrue(state.isSaveEnabled)
    }

    func test_isSaveEnabled_true_for20CharBoundary() {
        // Exactly 20 chars — save enabled ✅
        var state = LocationDetailState()
        state.updateNickname(String(repeating: "a", count: 20))
        XCTAssertTrue(state.isSaveEnabled)
    }

    func test_isSaveEnabled_false_for21CharOverBoundary() {
        // 21 chars — too long — save disabled ✅
        var state = LocationDetailState()
        state.updateNickname(String(repeating: "a", count: 21))
        XCTAssertFalse(state.isSaveEnabled)
    }

    // MARK: - updateNickname atomicity

    func test_updateNickname_setsAllThreePropertiesAtOnce() {
        // Given — valid nickname
        var state = LocationDetailState()

        // When
        state.updateNickname("Home")

        // Then — all three set correctly in one call ✅
        XCTAssertEqual(state.nickname, "Home")
        XCTAssertFalse(state.isNicknameTooLong)
        XCTAssertTrue(state.isSaveEnabled)
    }

    func test_updateNickname_tooLong_setsAllThreeCorrectly() {
        // Given — too long nickname
        var state = LocationDetailState()
        let tooLong = String(repeating: "x", count: 21)

        // When
        state.updateNickname(tooLong)

        // Then — all three set correctly ✅
        XCTAssertEqual(state.nickname, tooLong)
        XCTAssertTrue(state.isNicknameTooLong)
        XCTAssertFalse(state.isSaveEnabled)
    }

    func test_updateNickname_overwrite_updatesCorrectly() {
        // Given — set valid then overwrite with empty
        var state = LocationDetailState()
        state.updateNickname("Home")
        XCTAssertTrue(state.isSaveEnabled)

        // When
        state.updateNickname("")

        // Then — correctly reflects new empty state ✅
        XCTAssertEqual(state.nickname, "")
        XCTAssertFalse(state.isSaveEnabled)
    }

    func test_updateNickname_fromTooLong_backToValid() {
        // Given — too long
        var state = LocationDetailState()
        state.updateNickname(String(repeating: "a", count: 21))
        XCTAssertFalse(state.isSaveEnabled)

        // When — corrected to valid
        state.updateNickname("Home")

        // Then — save enabled again ✅
        XCTAssertTrue(state.isSaveEnabled)
        XCTAssertFalse(state.isNicknameTooLong)
    }

    // MARK: - Mutation
    func test_setErrorMessage_updatesValue() {
        var state = LocationDetailState()
        state.errorMessage = "Save failed"
        XCTAssertEqual(state.errorMessage, "Save failed")
    }

    func test_clearErrorMessage_setsNil() {
        var state = LocationDetailState()
        state.errorMessage = "Error"
        state.errorMessage = nil
        XCTAssertNil(state.errorMessage)
    }
}
