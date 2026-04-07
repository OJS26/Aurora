import SwiftUI

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    
    var body: some View {
        ZStack {
            AlarmListView()
            
            if alarmManager.isAlarmFiring, let alarm = alarmManager.activeAlarm {
                AlarmFiringView(alarm: alarm) {
                    alarmManager.stopAlarm()
                }
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut, value: alarmManager.isAlarmFiring)
    }
}
