import Foundation
import SwiftData

@Model
class Alarm {
    var id: UUID
    var time: Date
    var label: String
    var isEnabled: Bool
    var taskType: TaskType
    var qrCodeValue: String
    var repeatDays: [Int]
    
    init(time: Date, label: String = "", taskType: TaskType = .qrCode, repeatDays: [Int] = []) {
        self.id = UUID()
        self.time = time
        self.label = label
        self.isEnabled = true
        self.taskType = taskType
        self.qrCodeValue = UUID().uuidString
        self.repeatDays = repeatDays
    }
}

enum TaskType: String, Codable {
    case qrCode = "QR Code"
    case pushUps = "Push Ups"
    case photo = "Photo"
}
