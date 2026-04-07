import SwiftUI
import SwiftData

@main
struct AuroraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Alarm.self)
    }
}
