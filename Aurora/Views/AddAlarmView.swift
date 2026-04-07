import SwiftUI
import SwiftData

struct AddAlarmView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var time = Date()
    @State private var label = ""
    @State private var taskType = TaskType.qrCode
    @State private var stars: [(x: CGFloat, y: CGFloat, size: CGFloat, opacity: Double)] = []
    
    let amber = Color(red: 1.0, green: 0.75, blue: 0.3)
    let darkSurface = Color(white: 0.1)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Deep space background
                Color(red: 0.04, green: 0.04, blue: 0.08)
                    .ignoresSafeArea()
                
                // Stars
                GeometryReader { geo in
                    ForEach(0..<stars.count, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(stars[i].opacity))
                            .frame(width: stars[i].size, height: stars[i].size)
                            .position(
                                x: stars[i].x * geo.size.width,
                                y: stars[i].y * geo.size.height
                            )
                    }
                }
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Time picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WAKE UP TIME")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.orange.opacity(0.8))
                                .padding(.horizontal, 4)
                            
                            DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .frame(maxWidth: .infinity)
                                .background(darkSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .colorMultiply(amber)
                        }
                        .padding(.horizontal)
                        
                        // Label
                        VStack(alignment: .leading, spacing: 8) {
                            Text("LABEL")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.orange.opacity(0.8))
                                .padding(.horizontal, 4)
                            
                            TextField("Optional label e.g. Morning Rise", text: $label)
                                .foregroundStyle(amber)
                                .tint(amber)
                                .padding()
                                .background(darkSurface)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                        
                        // Task picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("WAKE-UP TASK")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.orange.opacity(0.8))
                                .padding(.horizontal, 4)
                            
                            Picker("Task", selection: $taskType) {
                                ForEach([TaskType.qrCode, .pushUps, .photo], id: \.self) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(maxWidth: .infinity)
                            .background(darkSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .colorMultiply(amber)
                        }
                        .padding(.horizontal)
                        
                        // Task description
                        HStack(spacing: 12) {
                            Text(taskEmoji(taskType))
                                .font(.title2)
                            Text(taskDescription(taskType))
                                .font(.subheadline)
                                .foregroundStyle(Color(white: 0.65))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(darkSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        
                        // Save button
                        Button {
                            saveAlarm()
                        } label: {
                            Text("Set Alarm")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .foregroundStyle(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color(white: 0.6))
                }
            }
            .onAppear {
                generateStars()
            }
        }
    }
    
    func generateStars() {
        stars = (0..<80).map { _ in
            (
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...2.5),
                opacity: Double.random(in: 0.2...0.7)
            )
        }
    }
    
    func taskEmoji(_ type: TaskType) -> String {
        switch type {
        case .qrCode: return "📍"
        case .pushUps: return "💪"
        case .photo: return "📸"
        }
    }
    
    func taskDescription(_ type: TaskType) -> String {
        switch type {
        case .qrCode: return "Scan a QR label placed somewhere that gets you out of bed."
        case .pushUps: return "Do 10 push ups with your phone on the floor."
        case .photo: return "Take a photo of something in another room."
        }
    }
    
    func saveAlarm() {
        let alarm = Alarm(time: time, label: label, taskType: taskType)
        modelContext.insert(alarm)
        AlarmManager.shared.scheduleAlarm(alarm)
        dismiss()
    }
}
