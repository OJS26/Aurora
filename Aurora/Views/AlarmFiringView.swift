import SwiftUI

struct AlarmFiringView: View {
    let alarm: Alarm
    let onComplete: () -> Void
    
    @State private var timeRemaining = 300 // 5 minutes
    @State private var timer: Timer? = nil
    @State private var showingTask = false
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Pulsing orange circle
            Circle()
                .fill(Color.orange.opacity(0.15))
                .frame(width: 300, height: 300)
                .scaleEffect(showingTask ? 1.1 : 0.9)
                .animation(.easeInOut(duration: 1.5).repeatForever(), value: showingTask)
            
            VStack(spacing: 32) {
                Spacer()
                
                // Time
                Text(alarm.time, format: .dateTime.hour().minute())
                    .font(.system(size: 72, weight: .thin))
                    .foregroundStyle(.white)
                
                // Label
                Text(alarm.label.isEmpty ? "Time to wake up!" : alarm.label)
                    .font(.title3)
                    .foregroundStyle(.gray)
                
                Spacer()
                
                // Countdown
                VStack(spacing: 8) {
                    Text("Complete your task to dismiss")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    Text(timeString(timeRemaining))
                        .font(.system(size: 36, weight: .light, design: .monospaced))
                        .foregroundStyle(timeRemaining < 60 ? .red : .orange)
                }
                
                // Task button
                Button {
                    showingTask = true
                } label: {
                    HStack {
                        Image(systemName: taskIcon(alarm.taskType))
                        Text(alarm.taskType.rawValue)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                
                Spacer()
                    .frame(height: 32)
            }
        }
        .onAppear {
            showingTask = true
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .sheet(isPresented: $showingTask) {
            TaskView(alarm: alarm, onComplete: onComplete)
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
    
    func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    func taskIcon(_ type: TaskType) -> String {
        switch type {
        case .qrCode: return "qrcode.viewfinder"
        case .pushUps: return "figure.strengthtraining.functional"
        case .photo: return "camera.fill"
        }
    }
}
