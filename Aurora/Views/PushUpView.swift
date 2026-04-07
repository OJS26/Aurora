import SwiftUI
import CoreMotion

struct PushUpView: View {
    let alarm: Alarm
    let onComplete: () -> Void
    
    @State private var repCount = 0
    @State private var targetReps = 10
    @State private var isDown = false
    @State private var motionManager = CMMotionManager()
    @State private var showSuccess = false
    
    var progress: Double {
        min(Double(repCount) / Double(targetReps), 1.0)
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                Text("Push Ups")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                
                Text("Place your phone on the floor and do your push ups")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // Progress circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 12)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .frame(width: 200, height: 200)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                    
                    VStack(spacing: 4) {
                        Text("\(repCount)")
                            .font(.system(size: 64, weight: .thin))
                            .foregroundStyle(.white)
                        Text("of \(targetReps)")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                }
                
                if showSuccess {
                    Text("✅ You're up! Let's go!")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.orange)
                } else {
                    Text(isDown ? "⬇️ Down" : "⬆️ Up")
                        .font(.title3)
                        .foregroundStyle(isDown ? .red : .orange)
                        .animation(.easeInOut, value: isDown)
                }
                
                Spacer()
            }
        }
        .onAppear {
            startDetecting()
        }
        .onDisappear {
            motionManager.stopAccelerometerUpdates()
        }
    }
    
    func startDetecting() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { data, error in
            guard let data else { return }
            
            let z = data.acceleration.z
            
            if z > 0.3 && !isDown {
                isDown = true
            } else if z < -0.3 && isDown {
                isDown = false
                repCount += 1
                
                if repCount >= targetReps {
                    motionManager.stopAccelerometerUpdates()
                    showSuccess = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        onComplete()
                    }
                }
            }
        }
    }
}
