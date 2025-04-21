//
//  BackgroundTaskManager.swift
//  Housing Monitor
//
//  Created by Vlad Andres on 20/04/2025.
//

import BackgroundTasks
import UIKit

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    
    func scheduleBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: "refresh-task")
        let interval = UserDefaults.standard.double(forKey: "checkInterval")
        request.earliestBeginDate = Date(timeIntervalSinceNow: (60 * interval))
        print("⚠️ Background task scheduling at \(interval) minutes")

        do {
            try BGTaskScheduler.shared.submit(request)
            BGTaskScheduler.shared.getPendingTaskRequests { tasks in
                let beginDate = tasks[0].earliestBeginDate
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                formatter.dateStyle = .none
                let timeString = formatter.string(from: beginDate!)
                
                Task {
                    await NotificationService.shared.sendSimpleNotification(
                        with: "Next job scheduled at \(timeString)"
                    )
                }
            }
            print("✅ scheduled")
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
//    func performBackgroundCheck(task: BGAppRefreshTask) {
//        print("Performing task ... 🔍")
//        // Schedule next task first thing
//        scheduleBackgroundTask()
//        
//        // Check if monitoring is enabled
//        guard UserDefaults.standard.bool(forKey: "isMonitoringEnabled") else {
//            task.setTaskCompleted(success: true)
//            return
//        }
//        
//        // Create task expiration handler
//        task.expirationHandler = {
//            task.setTaskCompleted(success: false)
//        }
//        
//        // Perform the check
//        ListingService.shared.checkForNewListings { newListings in
//            print("Found \(newListings.count) new listings ")
//            if !newListings.isEmpty {
//                NotificationService.shared.sendNotification(for: newListings)
//            }
//            task.setTaskCompleted(success: true)
//        }
//    }
    
    func performBackgroundCheckNow() async {
        print("🟢 Running manual check...")
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            print("\(requests.count) pending tasks")
//            try? BGTaskScheduler.shared.submit(requests[0])
        }
//        let newListings = await ListingService.shared.newListings()

    }

    
    func cancelAllTasks() {
        print("🛑 stopping all tasks")
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
}

//
//class BackgroundTaskManager {
//    static let shared = BackgroundTaskManager()
//    
//    func scheduleBackgroundTask() {
//        // Get the AppDelegate instance
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            appDelegate.scheduleAppRefresh()
//        }
//    }
//    
//    func performBackgroundCheckNow() async {
//        print("🟢 Running manual check...")
//        let newListings = await ListingService.shared.newListings()
//        
//        if !newListings.isEmpty {
//            print("Found \(newListings.count) new listings")
//            await NotificationService.shared.sendNotification(for: newListings)
//        }
//    }
//    
//    func cancelAllTasks() {
//        print("🛑 stopping all tasks")
//        BGTaskScheduler.shared.cancelAllTaskRequests()
//    }
//}
