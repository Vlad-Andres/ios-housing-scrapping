//
//  NotificationService.swift
//  Housing Monitor
//
//  Created by Vlad Andres on 20/04/2025.
//

import UserNotifications


class NotificationService {
    static let shared = NotificationService()
    
    func sendNotification(for newListings: [Listing]) async {
        let content = UNMutableNotificationContent()
        content.title = "New Listings Found!"
        
        if newListings.count == 1 {
            content.body = "New listing: \(newListings[0].title)"
        } else {
            content.body = "\(newListings.count) new listings found"
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("📛 Failed to schedule notification: \(error)")
        }
    }
    
    func sendSimpleNotification(with message: String) async {
        let content = UNMutableNotificationContent()
        content.title = "Housing Monitor"
        content.body = message
        content.sound = .defaultRingtone
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("📛 Failed to schedule notification: \(error)")
        }
    }
        
}
