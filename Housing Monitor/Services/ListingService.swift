import Foundation
import SwiftSoup

// MARK: - Listing Model
struct Listing: Identifiable {
    let id = UUID()
    let title: String
    let url: String
    let price: String
    let age: String
    let isNew: Bool
    
    // Initialize with isNew flag
    init(title: String, url: String, isNew: Bool = false, price: String, age: String) {
        self.title = title
        self.url = url
        self.isNew = isNew
        self.price = price
        self.age = age
    }
}

class ListingService {
    static let shared = ListingService()
    
    // Get all listings with new ones marked
    func getAllListings() async -> [Listing] {
        guard let urlString = UserDefaults.standard.string(forKey: "monitorURL") else {
            print("No URL specified")
            return []
        }
        
        let session = URLSession(configuration: .default)
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return []
        }
        
        let request = URLRequest(url: url)
        
        let response = await withTaskCancellationHandler {
            try? await session.data(for: request)
        } onCancel: {
            let task = session.downloadTask(with: request)
            task.resume()
        }
        
        guard let response = response else {
            print("Failed to fetch response")
            return []
        }
        
        let (data, _) = response
        guard let html = String(data: data, encoding: .utf8) else {
            print("Failed to decode HTML string")
            return []
        }

        let listings = parseListings(from: html)
        return markNewListings(listings)
    }
    
    // Get only new listings (for notifications)
    func newListings() async -> [Listing] {
        let allListings = await getAllListings()
        return allListings.filter { $0.isNew }
    }
    
    private func parseListings(from html: String) -> [Listing] {
        print("Parsing listings...")
        do {
            var results = [Listing]()
            let document: Document = try SwiftSoup.parse(html)
            let listingItems = try document.select("div.listing-search-item__content")
            
            for item in listingItems {
                let titleElement = try item.select("a.listing-search-item__link.listing-search-item__link--title")
                let title = try titleElement.text().trimmingCharacters(in: .whitespacesAndNewlines)
                let href = try titleElement.attr("href")
                
                let age = try item.select("p.listing-reactions-counter__details").text().trimmingCharacters(in: .whitespacesAndNewlines)
                let price = try item.select("div.listing-search-item__price").text().trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Create the full URL
                let baseUrl = "https://www.pararius.com"
                let fullUrl = href.starts(with: "http") ? href : baseUrl + href
                
                // Create a Listing object (isNew will be set later)
                let listing = Listing(title: title, url: fullUrl, price: price, age: age)
                results.append(listing)
            }
            return results
        } catch {
            print("Failed to parse HTML: \(error)")
            return []
        }
    }
    
    private func markNewListings(_ currentListings: [Listing]) -> [Listing] {
        // Get stored listing titles
        let storedTitles = UserDefaults.standard.stringArray(forKey: "lastListingTitles") ?? []
        
        // Mark listings as new if they don't exist in stored titles
        let markedListings = currentListings.map { listing in
            return Listing(
                title: listing.title,
                url: listing.url,
                isNew: !storedTitles.contains(listing.title),
                price: listing.price,
                age: listing.age
            )
        }
        
        // Get only the new listings
        let newListings = markedListings.filter { $0.isNew }
        
        if !newListings.isEmpty {
            // Store the current listing titles
            let currentTitles = currentListings.map { $0.title }
            UserDefaults.standard.set(currentTitles, forKey: "lastListingTitles")
        }
        
        return markedListings
    }
}
