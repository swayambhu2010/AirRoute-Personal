# mvldev-assignment-bf-d0-17-74-2e-ef-aa-8c-iOS-Swayambhu-Jyoti-Bangerjee
iOS test
https://www.notion.so/mvlchain/MVL-iOS-Developer-Assignment-286d814b821b80c081f5f9d4af5791b6

# ✈️ AirRoute

A clean-architecture iOS app for booking air routes between two locations, with real-time AQI (Air Quality Index) monitoring.

---

## 🎬 App Demo

![Watch Demo](https://github.com/creator-33/mvldev-assignment-bf-d0-17-74-2e-ef-aa-8c-iOS-Swayambhu-Jyoti-Bangerjee/blob/main/Demo.gif)

---

## 🏗️ Architecture

AirRoute is built with a strict **Unidirectional Data Flow** architecture.

```
View
 └── ViewModel          (ObservableObject + @Published state)
      └── UseCase        (single responsibility, protocol-driven)
           └── Repository (single source of truth)
                └── Network / Cache
```

### Design Principles

| Principle | Implementation |
|---|---|
| Unidirectional Data Flow | `send(_ action:)` → state mutation → View re-render |
| Single Responsibility | Each UseCase does exactly one thing |
| Dependency Inversion | All dependencies injected via protocols |
| No business logic in Views | Views only send actions, never mutate state |
| Testability | Every layer is independently testable via mocks |

---

## 🖥️ Screens

| Screen | Description |
|---|---|
| **Screen 1 — Map** | Full-screen map with draggable pin, A/B location slots, AQI badge, V button |
| **Screen 2 — Location Detail** | Address display, nickname input (max 20 chars), cache-backed |
| **Screen 3 — Booking** | Fare display, booking confirmation, history shortcut |
| **Screen 4 — History** | Monthly booking history, tap to re-book |
| **Screen 5 — Saved Locations** | Cached locations with nicknames, tap to pre-fill map |

---

## 🔄 User Flow

```
App Launch
    └── GPS received (one-shot)
         └── Map centers on GPS
              └── User drags pin → AQI updates (debounced 0.5s)
                   └── V Button → Set A
                        └── V Button → Set B
                             └── V Button → Book (Screen 3)
                                  └── Success → Go to History (Screen 4)
                                  └── Back   → Reset map to GPS ✅
```

---

## 🧠 State Management

Every ViewModel follows the same pattern:

```swift
// 1. State is a plain struct — pure value type
struct MapState {
    var mapCenter: CLLocationCoordinate2D?
    var locationA: LocationPoint?
    var buttonState: ButtonState = .setA
    // ...
}

// 2. Actions are an enum — exhaustive, readable
enum MapAction {
    case onAppear
    case vButtonTapped
    case initialLocationReceived(CLLocationCoordinate2D)
    // ...
}

// 3. ViewModel owns state mutation
func send(_ action: MapAction) {
    switch action {
    case .vButtonTapped:
        setLocation(for: state.mapCenter)
    // ...
    }
}
```

---

## 📍 AQI Behaviour

| Trigger | Behaviour |
|---|---|
| App launch / GPS received | Full fetch: address + AQI |
| Map drag stops | AQI only, debounced **0.5s** |
| Screen 1 resumes from Screen 2/3 | AQI only, immediate |
| V button tapped (Set A / Set B) | Full fetch: address + AQI |
| AQI fetch fails | **Silent failure** — existing value preserved, no error shown |

---

## 💾 Caching Strategy

| Data | Cached? | TTL |
|---|---|---|
| Location address | ✅ Yes | Configurable |
| Nickname | ✅ Yes | Permanent until cleared |
| AQI | ❌ Never | Always live |

---

## 🧪 Testing

### Test Philosophy

```
Each layer tests its OWN logic
Each layer mocks everything BELOW it

View         → not unit tested (SwiftUI)
ViewModel    → mocks UseCases
UseCase      → mocks Repository
Repository   → mocks Network / Cache (future)
```

### Test Coverage by Layer

| Layer | File | Tests |
|---|---|---|
| State | `MapStateTests` | 30+ |
| ViewModel | `MapViewModelTests` | 10 |
| ViewModel | `LocationDetailViewModelTests` | 10 |
| UseCase | `FetchAQIUseCaseTests` | 9 |
| UseCase | `FetchCachedLocationUseCaseTests` | 8 |
| UseCase | `FetchLocationInfoUseCaseTests` | 7 |
| UseCase | `UpdateNicknameUseCaseTests` | 17 |
| **Total** | | **100+** |

### Running Tests

```bash
# Run all tests
cmd + U

# Run a single test file
cmd + ctrl + U  (cursor inside test file)
```

### Mock Strategy

Every external dependency has a mock:

```swift
// Example — control result, track calls
final class MockFetchAQIUseCase: FetchAQIUseCaseProtocol {
    var result: Result<Int, Error> = .success(42)
    var callCount = 0

    func execute(latitude: Double, longitude: Double) async throws -> Int {
        callCount += 1
        switch result {
        case .success(let aqi): return aqi
        case .failure(let error): throw error
        }
    }
}
```

---

## 🔌 Dependencies

| Library | Purpose |
|---|---|
| **Alamofire** | HTTP networking |
| **GoogleMaps** | Interactive map, pin overlay |
| **CoreLocation** | GPS / device location |
| **Combine** | Reactive state binding |
| **SwiftUI** | UI framework |
---

## ⚙️ Requirements

| Requirement | Version |
|---|---|
| iOS | 16+ |
| Xcode | 14+ |
| Swift | 5+ |

---

## 🚀 Getting Started

```bash
# 1. Clone the repository
git clone https://github.com/your-username/AirRoute.git

# 2. Open in Xcode
open AirRoute.xcodeproj

# 3. Select a simulator or device
# iPhone 15 Pro recommended

# 4. Build and run
cmd + R

# 5. Run tests
cmd + U
```

---

## 🔑 API Keys

AirRoute uses the following external APIs:

| API | Purpose |
|---|---|
| [BigDataCloud](https://www.bigdatacloud.com) | Reverse geocoding (address from coordinates) |
| [AQICN](https://aqicn.org/api/) | Live Air Quality Index |

> ⚠️ **Security Notice**
>
> API keys have been **intentionally committed** to this repository
> **for demo and evaluation purposes only.**
>
> In a production project, API keys must **never** be committed to
> version control. They should be stored in:
> - A `.gitignore`-d `Config.plist` or `Secrets.swift`
> - Environment variables via CI/CD
> - A secrets manager (e.g. AWS Secrets Manager, Vault)
>
> This repo exists solely to demonstrate architecture,
> clean code, and testing practices.

---

## 👤 Author

**Swayambhu Banerjee**
Created: March 2026
