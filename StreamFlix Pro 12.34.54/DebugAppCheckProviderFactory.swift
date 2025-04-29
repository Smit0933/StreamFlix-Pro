import FirebaseAppCheck
import FirebaseCore

#if targetEnvironment(simulator)

/// A fallback Debug AppCheck provider factory for Simulator use.
class DebugAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return DebugAppCheckProvider(app: app)
    }
}

/// A stub Debug AppCheck provider (only used in simulator)
class DebugAppCheckProvider: NSObject, AppCheckProvider {
    let app: FirebaseApp

    init(app: FirebaseApp) {
        self.app = app
    }

    func getToken(completion: @escaping (AppCheckToken?, Error?) -> Void) {
        let token = AppCheckToken(
            token: "debug-simulator-token",
            expirationDate: Date().addingTimeInterval(60 * 60) // valid for 1 hour
        )
        completion(token, nil)
    }
}
#endif
