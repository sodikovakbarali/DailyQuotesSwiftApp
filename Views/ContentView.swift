import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuoteViewModel()
    @State private var showFavorites = false
    @State private var bgColor = Color.white

    var body: some View {
        NavigationView {
            VStack {
                if !viewModel.quotes.isEmpty {
                    QuoteCardView(quote: viewModel.quotes[viewModel.currentIndex])
                        .padding()

                    HStack(spacing: 30) {
                        Button(action: viewModel.previousQuote) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                        }
                        Button(action: {
                            viewModel.favoriteCurrentQuote()
                        }) {
                            Image(systemName: viewModel.isFavorite(viewModel.quotes[viewModel.currentIndex]) ? "heart.fill" : "heart")
                                .font(.largeTitle)
                        }
                        Button(action: {
                            viewModel.nextQuote()
                            bgColor = Color.random()
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.largeTitle)
                        }
                        Button(action: {
                            shareQuote(viewModel.quotes[viewModel.currentIndex])
                        }) {
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.largeTitle)
                        }
                    }
                    .padding(.top)
                } else {
                    Text("Loading quotes...")
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .navigationBarTitle("Daily Quotes", displayMode: .inline)
            .navigationBarItems(trailing: Button("Favorites") {
                showFavorites = true
            })
            .sheet(isPresented: $showFavorites) {
                FavoritesView(viewModel: viewModel)
            }
            .background(bgColor.ignoresSafeArea())
            .animation(.easeInOut, value: viewModel.currentIndex)
        }
    }

    func shareQuote(_ quote: Quote) {
        let quoteText = "“\(quote.text)” — \(quote.author)"
        let av = UIActivityViewController(activityItems: [quoteText], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }
}

extension Color {
    static func random() -> Color {
        Color(
            red: .random(in: 0.6...1),
            green: .random(in: 0.6...1),
            blue: .random(in: 0.6...1)
        )
    }
}
