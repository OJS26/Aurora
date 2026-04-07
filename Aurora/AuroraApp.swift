import SwiftUI
import SwiftData

@main
struct AuroraApp: App {
    @StateObject private var alarmManager = AlarmManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alarmManager)
                .onAppear {
                    alarmManager.requestPermissions()
                }
        }
        .modelContainer(for: Alarm.self)
    }
}
