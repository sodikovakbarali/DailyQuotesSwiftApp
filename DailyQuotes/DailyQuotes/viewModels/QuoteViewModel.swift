import Foundation
import SwiftUI

class QuoteViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var currentIndex: Int = 0
    @Published var favorites: [Quote] = []
    @Published var loadingError: String? = nil

    private let favoritesKey = "FavoriteQuotes"

    init() {
        loadQuotes()
        loadFavorites()
    }

    func loadQuotes() {
        // Trying all possible paths to the file
        var possiblePaths = [
            Bundle.main.url(forResource: "quotes", withExtension: "json"),
            Bundle.main.url(forResource: "Resources/quotes", withExtension: "json"),
            Bundle.main.url(forResource: "quotes", withExtension: "json", subdirectory: "Resources")
        ]
        
        if let resourcePath = Bundle.main.resourcePath {
            print("Resource path: \(resourcePath)")
        }
        
        // Looking for the file JSON in all possible places
        if let url = possiblePaths.compactMap({ $0 }).first {
            do {
                let data = try Data(contentsOf: url)
                let decodedQuotes = try JSONDecoder().decode([Quote].self, from: data)
                self.quotes = decodedQuotes
                self.loadingError = nil
                print("Quotes successfully loaded from \(url.absoluteString)")
            } catch let error {
                print("Error decoding JSON: \(error.localizedDescription)")
                self.loadingError = "Error loading quotes: \(error.localizedDescription)"
                loadHardcodedQuotes()
            }
        } else {
            print("Failed to find quotes.json file in the bundle")
            self.loadingError = "Quotes.json file not found in the bundle"
            loadHardcodedQuotes()
        }
    }
    
    private func loadHardcodedQuotes() {
        // Hardcoded quotes, encoded in the application
        self.quotes = [
            Quote(text: "The best way to get started is to quit talking and begin doing.", author: "Walt Disney"),
            Quote(text: "Don't let yesterday take up too much of today.", author: "Will Rogers"),
            Quote(text: "It's not whether you get knocked down, it's whether you get up.", author: "Vince Lombardi"),
            Quote(text: "If you are working on something exciting, it will keep you motivated.", author: "Steve Jobs"),
            Quote(text: "Success is not in what you have, but who you are.", author: "Bo Bennett"),
            Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt")
        ]
    }

    func nextQuote() {
        if currentIndex < quotes.count - 1 {
            currentIndex += 1
        }
    }

    func previousQuote() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }

    func favoriteCurrentQuote() {
        let currentQuote = quotes[currentIndex]
        if !favorites.contains(currentQuote) {
            favorites.append(currentQuote)
            saveFavorites()
        }
    }

    func unfavorite(quote: Quote) {
        favorites.removeAll { $0 == quote }
        saveFavorites()
    }

    func isFavorite(_ quote: Quote) -> Bool {
        favorites.contains(quote)
    }

    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: favoritesKey)
        }
    }

    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let decoded = try? JSONDecoder().decode([Quote].self, from: data) {
            favorites = decoded
        }
    }
}
