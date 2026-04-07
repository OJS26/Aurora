import SwiftUI
import SwiftData

struct AddAlarmView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var time = Date()
    @State private var label = ""
    @State private var taskType = TaskType.qrCode
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section {
                        DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                    
                    Section("Label") {
                        TextField("Optional label", text: $label)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                    
                    Section("Wake-up task") {
                        Picker("Task", selection: $taskType) {
                            ForEach([TaskType.qrCode, .pushUps, .photo], id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowBackground(Color.gray.opacity(0.15))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Alarm")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveAlarm()
                    }
                    .foregroundStyle(.orange)
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    func saveAlarm() {
        let alarm = Alarm(time: time, label: label, taskType: taskType)
        modelContext.insert(alarm)
        dismiss()
    }
}
