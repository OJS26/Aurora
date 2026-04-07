import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var alarmManager: AlarmManager
    @Query var alarms: [Alarm]
    
    var body: some View {
        ZStack {
            AlarmListView()
            
            if alarmManager.isAlarmFiring {
                if let alarm = alarmManager.activeAlarm ?? alarms.first(where: { $0.isEnabled }) {
                    AlarmFiringView(alarm: alarm) {
                        alarmManager.stopAlarm()
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
        .animation(.easeInOut, value: alarmManager.isAlarmFiring)
        .onChange(of: alarmManager.isAlarmFiring) {
            if alarmManager.isAlarmFiring {
                if let alarm = alarms.first(where: { $0.isEnabled }) {
                    alarmManager.activeAlarm = alarm
                    alarmManager.startSound()
                }
            }
        }
    }
}
