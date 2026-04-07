import SwiftUI

struct AlarmRowView: View {
    @Bindable var alarm: Alarm
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(alarm.time, format: .dateTime.hour().minute())
                    .font(.system(size: 48, weight: .thin, design: .default))
                    .foregroundStyle(.white)
                Text(alarm.label.isEmpty ? alarm.taskType.rawValue : alarm.label)
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $alarm.isEnabled)
                .tint(.orange)
        }
        .padding(.vertical, 8)
    }
}
