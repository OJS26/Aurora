import SwiftUI

struct AlarmRowView: View {
    @Bindable var alarm: Alarm
    @EnvironmentObject var alarmManager: AlarmManager
    @State private var showingQR = false
    @State private var showingEdit = false
    
    let amber = Color(red: 1.0, green: 0.75, blue: 0.3)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.time, format: .dateTime.hour().minute())
                    .font(.system(size: 48, weight: .thin))
                    .foregroundStyle(alarm.isEnabled ? .white : .gray)
                Text(alarm.label.isEmpty ? alarm.taskType.rawValue : alarm.label)
                    .font(.subheadline)
                    .foregroundStyle(alarm.isEnabled ? amber.opacity(0.8) : .gray)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Toggle("", isOn: $alarm.isEnabled)
                    .tint(.orange)
                    .onChange(of: alarm.isEnabled) {
                        if alarm.isEnabled {
                            alarmManager.scheduleAlarm(alarm)
                        } else {
                            alarmManager.cancelAlarm(alarm)
                        }
                    }
                
                HStack(spacing: 16) {
                    // Edit button
                    Button {
                        showingEdit = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundStyle(amber.opacity(0.7))
                            .font(.subheadline)
                    }
                    
                    // QR button (only for QR task type)
                    if alarm.taskType == .qrCode {
                        Button {
                            showingQR = true
                        } label: {
                            Image(systemName: "qrcode")
                                .foregroundStyle(amber.opacity(0.7))
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingQR) {
            QRCodeView(alarm: alarm)
        }
        .sheet(isPresented: $showingEdit) {
            EditAlarmView(alarm: alarm)
        }
    }
}
