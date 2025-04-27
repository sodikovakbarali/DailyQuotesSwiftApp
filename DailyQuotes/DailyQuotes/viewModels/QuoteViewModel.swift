import Foundation
import SwiftUI

class QuoteViewModel: ObservableObject {
    @Published var quotes: [Quote] = []
    @Published var currentIndex: Int = 0
    @Published var favorites: [Quote] = []

    private let favoritesKey = "FavoriteQuotes"

    init() {
        loadQuotes()
        loadFavorites()
    }

    func loadQuotes() {
        if let url = Bundle.main.url(forResource: "quotes", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let decodedQuotes = try? JSONDecoder().decode([Quote].self, from: data) {
            self.quotes = decodedQuotes
        }
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
