//
//  AppDelegate.swift
//  Housing Monitor
//
//  Created by Vlad Andres on 20/04/2025.
//


import UIKit
import BackgroundTasks

class AppDelegate: NSObject, UIApplicationDelegate {
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
//        print("App launched, registering background tasks")
//        registerBackgroundTasks()
//        return true
//    }
//    
//    func registerBackgroundTasks() {
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "refresh-task", using: nil) { task in
//            print("🔔 Background task triggered: \(Date().formatted())")
//            self.handleAppRefresh(task as! BGAppRefreshTask)
//        }
//    }
//    
//    func handleAppRefresh(_ task: BGAppRefreshTask) {
//        // Create a task expiration handler
//        task.expirationHandler = {
//            print("❌ Background task expired before completion")
//            task.setTaskCompleted(success: false)
//        }
//        
//        // Schedule the next task first
//        scheduleAppRefresh()
//        
//        // Perform your background work
//        Task {
//            print("🔍 Checking for new listings...")
//            let newListings = await ListingService.shared.newListings()
//            print("Found \(newListings.count) new listings")
//            
//            if !newListings.isEmpty {
//                await NotificationService.shared.sendNotification(for: newListings)
//            }
//            
//            // Mark task complete
//            task.setTaskCompleted(success: true)
//        }
//    }
//    
//    func scheduleAppRefresh() {
//        let request = BGAppRefreshTaskRequest(identifier: "refresh-task")
//        let interval = UserDefaults.standard.double(forKey: "checkInterval") * 60
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 10) // Force 10 seconds for testing
//        
//        do {
//            try BGTaskScheduler.shared.submit(request)
//            // Manual test: e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"refresh-task"]
//            print("✅ Next background check scheduled for \(request.earliestBeginDate?.formatted() ?? "unknown")")
//        } catch {
//            print("❌ Could not schedule background task: \(error)")
//        }
//    }
}
