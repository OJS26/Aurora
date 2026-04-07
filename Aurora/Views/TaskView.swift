import SwiftUI

struct TaskView: View {
    let alarm: Alarm
    let onComplete: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            switch alarm.taskType {
            case .qrCode:
                QRScanView(alarm: alarm, onComplete: {
                    dismiss()
                    onComplete()
                })
            case .pushUps:
                PushUpView(alarm: alarm, onComplete: {
                    dismiss()
                    onComplete()
                })
            case .photo:
                PhotoTaskView(alarm: alarm, onComplete: {
                    dismiss()
                    onComplete()
                })
            }
        }
    }
}
