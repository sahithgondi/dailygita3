import SwiftUI
import GitaKit

@main
struct DailyGitaApp: App {
    /// Built once. `UserStore` initializes the SwiftData + CloudKit stack; if that ever fails we
    /// fall back to an in-memory store so the shell still launches (Phase 0 is about a runnable
    /// shell on device — we never want a hard crash at launch).
    @State private var model: AppModel

    init() {
        let content = ContentStore()
        let user: UserStore
        do {
            user = try UserStore()
        } catch {
            // Fallback keeps the app runnable even if CloudKit/SwiftData can't initialize.
            user = try! UserStore(inMemory: true)
        }
        _model = State(initialValue: AppModel(contentStore: content, userStore: user))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .modelContainer(model.userStore.container)
        }
    }
}
