import SwiftUI

struct ListingsView: View {
//    @State private var listings: [Listing] = []
//    @State private var isLoading = true
    @EnvironmentObject var viewModel: ListingsViewModel
    
    // Separate listings into new and existing
    var newListings: [Listing] {
        viewModel.listings.filter { $0.isNew }
    }
    
    var existingListings: [Listing] {
        viewModel.listings.filter { !$0.isNew }
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                    Text("Loading listings...")
                        .padding()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Show new listings section if there are any
                        // 🔄 Refresh Button
                        Button(action: {
                            Task {
                                await viewModel.loadListings()
                            }
                        }) {
                            Label("Refresh Listings", systemImage: "arrow.clockwise")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                        if !newListings.isEmpty {
                            Section(header: Text("New Listings")
                                .font(.headline)
                                .padding(.bottom, 4)
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(newListings) { listing in
                                        ListingRow(listing: listing)
                                    }
                                }
                                .padding(.bottom, 12)
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                        }
                        
                        // Show all existing listings
                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(existingListings) { listing in
                                    ListingRow(listing: listing)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Housing Listings")
        .task {
            await viewModel.loadListings()
        }
        .refreshable {
            await viewModel.loadListings()
        }
    }
}

struct ListingRow: View {
    let listing: Listing
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(listing.title)
                        .font(.system(size: 15, weight: .medium))
                    
                    if listing.isNew {
                        Text("NEW")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue)
                            .cornerRadius(4)
                    }
                }
                
                if let url = URL(string: listing.url) {
                    Link(destination: url) {
                        HStack {
                            Text("View Listing")
                                .font(.system(size: 13))
                                .foregroundColor(.blue)
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 12))
                        }
                    }
                }
                
                Divider()
            }
            .padding(.vertical, 4)
            VStack(alignment: .trailing) {
                Text(listing.price)
                    .font(.system(size: 12, weight: .medium))
                
                Text(listing.age)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Custom Pull-to-Refresh
struct RefreshingView: View {
    @Binding var isRefreshing: Bool
    let action: () -> Void
    
    @State private var offset: CGFloat = 0
    private let threshold: CGFloat = 80
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                if offset > 0 {
                    VStack {
                        if isRefreshing {
                            ProgressView()
                                .frame(width: 30, height: 30)
                        } else {
                            Image(systemName: offset > threshold ? "arrow.up" : "arrow.down")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.gray)
                                .rotationEffect(.degrees(offset > threshold ? 180 : 0))
                                .animation(.easeInOut, value: offset > threshold)
                        }
                        Text(offset > threshold ? "Release to refresh" : "Pull to refresh")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .frame(height: min(offset, 120))
                    .frame(maxWidth: .infinity)
                }
            }
            .offset(y: -offset)
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: OffsetPreferenceKey.self,
                                    value: proxy.frame(in: .named("scrollView")).minY)
                }
            )
            .onPreferenceChange(OffsetPreferenceKey.self) { value in
                if !isRefreshing {
                    offset = max(value, 0)
                    if offset > threshold && value < threshold && value > 0 {
                        action()
                    }
                }
            }
        }
        .frame(height: 0)
    }
}
