//
//  AirRouteApp.swift
//  AirRoute
//
//  Created by Swayambhu BANERJEE on 14/03/26.
//

import SwiftUI
import GoogleMaps

@main
struct AirRouteApp: App {

    // MARK: - Core Objects
    // Created ONCE at app launch
    // Shared across all screens via environment
    @StateObject private var router = AppRouter(
        container: DIContainer()    // ← production
    )
    @StateObject private var locationManager = LocationManager()

    // MARK: - Google Maps SDK
    init() {
        // Provide API key before any map is rendered
        GMSServices.provideAPIKey(
            AppConfiguration.shared.googleMapsAPIKey
        )
    }

    // MARK: - Scene
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {

                // MARK: - Root Screen
                // Screen 1 — Map
                router.mapScreen
                    .navigationDestination(
                        for: Route.self
                    ) { route in
                        router.view(for: route)
                    }
            }
            // MARK: - Environment Objects
            // Available to ALL screens in the hierarchy
            .environmentObject(router)
            .environmentObject(locationManager)
        }
    }
}
