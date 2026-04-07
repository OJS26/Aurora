import SwiftUI

struct AlarmRowView: View {
    @Bindable var alarm: Alarm
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var showingQR = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.time, format: .dateTime.hour().minute())
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(alarm.isEnabled ? .white : .gray)
                Text(alarm.label.isEmpty ? alarm.taskType.rawValue : alarm.label)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .onTapGesture {
                if alarm.taskType == .qrCode {
                    showingQR = true
                }
            }
            
            Spacer()
            
            Toggle("", isOn: $alarm.isEnabled)
                .tint(.orange)
                .onChange(of: alarm.isEnabled) {
                    if alarm.isEnabled {
                        alarmManager.scheduleAlarm(alarm)
                    } else {
                        alarmManager.cancelAlarm(alarm)
                    }
                }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingQR) {
            QRCodeView(alarm: alarm)
        }
    }
}
