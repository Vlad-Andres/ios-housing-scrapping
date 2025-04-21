import SwiftUI

struct SettingsView: View {
    @AppStorage("monitorURL") private var monitorURL = "https://www.pararius.com/apartments/utrecht/0-1200"
    @AppStorage("checkInterval") private var checkInterval = 15.0 // in minutes
    @AppStorage("isMonitoringEnabled") private var isMonitoringEnabled = false
    
    @State private var isRunning: Bool = false
    @State private var secondsLeft: Int = 0
    @State private var timer: Timer? = nil
    @State private var navigateToListings = false
    @State private var isMonitoringSettingsExpanded = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Monitoring Settings Section
                    VStack(alignment: .leading, spacing: 8) {
                        Button(action: {
                            withAnimation {
                                isMonitoringSettingsExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text("Monitoring Settings")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: isMonitoringSettingsExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                        
                        if isMonitoringSettingsExpanded {
                            VStack(spacing: 16) {
                                Toggle("Enable Background Checks", isOn: $isMonitoringEnabled)
                                    .onChange(of: isMonitoringEnabled) {
                                        if isMonitoringEnabled && !isRunning {
                                            BackgroundTaskManager.shared.scheduleBackgroundTask()
                                            isRunning = true
                                            startTimer()
                                        } else {
                                            BackgroundTaskManager.shared.cancelAllTasks()
                                            isRunning = false
                                            stopTimer()
                                        }
                                    }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Website URL")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    TextField("Website URL", text: $monitorURL)
                                        .keyboardType(.URL)
                                        .autocapitalization(.none)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(8)
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Stepper("Check every \(Int(checkInterval)) minutes",
                                            value: $checkInterval, in: 1...60, step: 1)
                                    .onChange(of: checkInterval) {
                                        resetTimer()
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Status Section
                    if isMonitoringEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Status")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            Text("Next check in \(secondsLeft / 60) minutes")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Listings Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Listings")
                                .font(.title2)
                                .bold()
                                .padding(.top)
                            Spacer()
                            Button(role: .destructive) {
                                clearListings()
                            } label: {
                                Label("Clear data", systemImage: "trash")
                            }
//                            Button("Test Notification") {
//                                Task {
//                                    await NotificationService.shared.sendNotification(for: [
//                                        Listing(title: "Test Apartment", url: "https://www.example.com", price: "€1000", age: "1d") // example Listing
//                                    ])
//                                }
//                            }
                        }
 
                        ListingsView()
                            .frame(minHeight: 300)
                    }
                }.padding()
            }
        }
        .coordinateSpace(name: "scrollView") // ✅ Required for custom RefreshingView
        .navigationTitle("Listing Monitor")
        .onAppear {
            if isMonitoringEnabled {
                resetTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Timer Helpers
    func startTimer() {
        stopTimer()
        secondsLeft = Int(checkInterval * 60)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsLeft > 0 {
                secondsLeft -= 1
            } else {
                resetTimer()
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func resetTimer() {
        stopTimer()
        startTimer()
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private func clearListings() {
    print("Clearing listings")
    UserDefaults.standard.removeObject(forKey: "lastListingTitles")
}
