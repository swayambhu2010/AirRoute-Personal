//
//  LocationRepository.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//


import Foundation

final class LocationRepository: LocationRepositoryProtocol {

    // MARK: - Dependencies
    private let networkService: NetworkRequest
    private let cache: LocationCacheProtocol

    // MARK: - Init
    init(
        networkService: NetworkRequest,
        cache: LocationCacheProtocol
    ) {
        self.networkService = networkService
        self.cache = cache
    }

    // MARK: - Screen 1
    // Full fetch — address + live AQI
    // Called by FetchLocationInfoUseCase
    // Trigger: App launch, V button tap
    func fetchLocationInfo(
        latitude: Double,
        longitude: Double
    ) async throws -> LocationPoint {

        let key = CacheKeyGenerator.key(
            latitude: latitude,
            longitude: longitude
        )

        // Fetch address + AQI in parallel
        // Address → check cache first, API on miss
        // AQI     → always fresh from API
        async let addressPoint = fetchAddress(
            key: key,
            latitude: latitude,
            longitude: longitude
        )
        async let liveAQI = fetchAQIFromAPI(
            latitude: latitude,
            longitude: longitude
        )

        // Await both
        var locationPoint = try await addressPoint
        locationPoint.aqi = try await liveAQI

        // Cache complete location with fresh AQI
        cache.set(locationPoint, for: key)

        return locationPoint
    }

    // MARK: - Screen 1
    // Live AQI only — never cached
    // Called by FetchAQIUseCase
    // Trigger: Map drag stop (debounced), Screen resume
    func fetchLiveAQI(
        latitude: Double,
        longitude: Double
    ) async throws -> Int {
        return try await fetchAQIFromAPI(
            latitude: latitude,
            longitude: longitude
        )
    }

    // MARK: - Screen 2
    // Save nickname to cache
    // Called by UpdateNicknameUseCase
    func updateNickname(
        _ nickname: String,
        for location: LocationPoint
    ) throws {
        let key = CacheKeyGenerator.key(
            latitude: location.latitude,
            longitude: location.longitude
        )

        guard var cached = cache.get(for: key) else {
            throw LocationError.locationNotFound
        }

        guard nickname.count <= 20 else {
            throw LocationError.nicknameTooLong
        }

        // Empty string → clear nickname
        cached.nickname = nickname.isEmpty ? nil : nickname
        cache.set(cached, for: key)
    }

    // Read single location from cache
    // Called by FetchCachedLocationUseCase
    func fetchCachedLocation(
        latitude: Double,
        longitude: Double
    ) -> LocationPoint? {
        let key = CacheKeyGenerator.key(
            latitude: latitude,
            longitude: longitude
        )
        return cache.get(for: key)
    }

    // MARK: - Screen 5
    // Read all cached locations
    // Called by FetchSavedLocationsUseCase
    func fetchAllCachedLocations() -> [LocationPoint] {
        return cache.getAll()
    }

    // Remove location from cache
    // Called by RemoveSavedLocationUseCase
    func removeCachedLocation(
        _ location: LocationPoint
    ) {
        let key = CacheKeyGenerator.key(
            latitude: location.latitude,
            longitude: location.longitude
        )
        cache.remove(for: key)
    }

    // MARK: - Private Helpers

    private func fetchAddress(
        key: String,
        latitude: Double,
        longitude: Double
    ) async throws -> LocationPoint {

        // Use getAddressOnly — address is static
        // Even if AQI is expired the name is still valid
        // Avoids unnecessary BigDataCloud API calls ✅
        if let cached = cache.getAddressOnly(for: key) {
            return cached
        }

        // Cache miss or address TTL expired → call API
        return try await fetchAddressFromAPI(
            latitude: latitude,
            longitude: longitude
        )
    }

    // BigDataCloud reverse geocode
    private func fetchAddressFromAPI(
        latitude: Double,
        longitude: Double
    ) async throws -> LocationPoint {
        let dto: ReverseGeocodeDTO = try await networkService.request(
            apiRequest: ReverseGeocodeEndpoint.reverseGeocode(
                latitude: latitude,
                longitude: longitude
            )
        )
        return dto.toDomain()
    }

    // AQI API call
    // Always called fresh — never from cache
    private func fetchAQIFromAPI(
        latitude: Double,
        longitude: Double
    ) async throws -> Int {
        let dto: AQIResponseDTO = try await networkService.request(
            apiRequest: AQIEndpoint.fetchAQI(
                latitude: latitude,
                longitude: longitude
            )
        )
        guard dto.isValid else {
            throw NetworkError.invalidResponse
        }
        return dto.data.aqi
    }
}
