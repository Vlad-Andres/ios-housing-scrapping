//
//  Housing_MonitorApp.swift
//  Housing Monitor
//
//  Created by Vlad Andres on 20/04/2025.
//

import SwiftUI
import BackgroundTasks

@main
struct Housing_MonitorApp: App {
    @Environment(\.scenePhase) private var phase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var viewModel = ListingsViewModel()
    let notificationDelegate = NotificationDelegate()


    init() {
        UNUserNotificationCenter.current().delegate = notificationDelegate
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            SettingsView()
        }
        .backgroundTask(.appRefresh("refresh-task")) {
            print("Performing task ... 🔍")
            // Schedule next task first thing
            await scheduleAppRefresh()
            
            // Perform the check
            await viewModel.loadListings()
            let newListings = await viewModel.newListings
            if !newListings.isEmpty {
                await NotificationService.shared.sendNotification(for: newListings)
            }
        }
        .backgroundTask(.urlSession("refresh-task")) {
            // Perform the check using the newListings method that fetches listings
            let newListings = await ListingService.shared.newListings()
            
            if !newListings.isEmpty {
                print("Found \(newListings.count) new listings in background")
                await NotificationService.shared.sendNotification(for: newListings)
            } else {
                await NotificationService.shared.sendNotification(for: [
                    Listing(title: "No listings", url: "-", price: "€-", age: "1d") // example Listing TODO: remove
                ])
            }
        }
        .onChange(of: phase) {
            switch phase {
            case .active:
                Task {
                    await viewModel.loadListings()
                    let newListings = viewModel.newListings
                    print(newListings.count)
                    if !newListings.isEmpty {
                        await NotificationService.shared.sendNotification(for: newListings)
                    }
                }
            default: break
            }
        }
        .environmentObject(viewModel)
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error)")
            } else {
                print("Permission granted: \(granted)")
            }
        }
    }

    func scheduleAppRefresh() {
        print("⚠️ Background task scheduling ...")

        let request = BGAppRefreshTaskRequest(identifier: "refresh-task")
        let interval = UserDefaults.standard.double(forKey: "checkInterval")
        request.earliestBeginDate = Date(timeIntervalSinceNow: (60 * interval))

        do {
            try BGTaskScheduler.shared.submit(request)
            print("✅ scheduled")
        } catch {
            print("Could not schedule background task: \(error)")
        }
    }
    
    class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
                                    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            // Show banner even if app is open
            completionHandler([.banner, .sound])
        }
    }
}
