//
//  ListingsViewModel.swift
//  Housing Monitor
//
//  Created by Vlad Andres on 21/04/2025.
//


import SwiftUI

@MainActor
class ListingsViewModel: ObservableObject {
    @Published var listings: [Listing] = []
    @Published var isLoading: Bool = true
    
    var newListings: [Listing] {
        listings.filter { $0.isNew }
    }
    
    var existingListings: [Listing] {
        listings.filter { !$0.isNew }
    }
    
    func loadListings() async {
        DispatchQueue.main.async {
            self.isLoading = true
        }
        let fetched = await ListingService.shared.getAllListings()
        DispatchQueue.main.async {
            self.listings = fetched
            self.isLoading = false
        }
    }
}
