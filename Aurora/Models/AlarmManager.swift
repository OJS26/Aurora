import Foundation
import UserNotifications
import AVFoundation
import SwiftData
import Combine

class AlarmManager: NSObject, ObservableObject {
    static let shared = AlarmManager()
    
    @Published var activeAlarm: Alarm? = nil
    @Published var isAlarmFiring = false
    
    private var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    // MARK: - Audio Setup
    func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }
    
    // MARK: - Schedule Alarm
    func scheduleAlarm(_ alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Aurora"
        content.body = alarm.label.isEmpty ? "Time to wake up! 🌅" : alarm.label
        content.sound = UNNotificationSound.defaultCritical
        content.userInfo = ["alarmID": alarm.id.uuidString]
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: alarm.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule alarm: \(error)")
            }
        }
    }
    
    // MARK: - Cancel Alarm
    func cancelAlarm(_ alarm: Alarm) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [alarm.id.uuidString]
        )
    }
    
    // MARK: - Fire Alarm (called when notification received)
    func fireAlarm(_ alarm: Alarm) {
        activeAlarm = alarm
        isAlarmFiring = true
        startSound()
    }
    
    // MARK: - Stop Alarm
    func stopAlarm() {
        audioPlayer?.stop()
        audioPlayer = nil
        isAlarmFiring = false
        activeAlarm = nil
    }
    
    // MARK: - Sound
    func startSound() {
        guard let url = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            print("Alarm sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        } catch {
            print("Audio player error: \(error)")
        }
    }
    
    // MARK: - Permissions
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Permission error: \(error)")
            }
        }
    }
}
