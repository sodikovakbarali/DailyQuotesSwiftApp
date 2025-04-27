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

                    if let error = viewModel.loadingError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                            .onAppear {
                                // Hides the error through 3 seconds, if the quotes are loaded
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    // If the quotes are loaded, clears the error
                                    if !viewModel.quotes.isEmpty {
                                        viewModel.loadingError = nil
                                    }
                                }
                            }
                    }

                    HStack(spacing: 30) {
                        Button(action: viewModel.previousQuote) {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.largeTitle)
                        }
                        .disabled(viewModel.currentIndex == 0)
                        
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
                        .disabled(viewModel.currentIndex >= viewModel.quotes.count - 1)
                        
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
                        .padding()
                    
                    if let error = viewModel.loadingError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    Button("Reload") {
                        viewModel.loadQuotes()
                    }
                    .padding()
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
            .onAppear {
                // If the quotes are not loaded at the first launch, reload them
                if viewModel.quotes.isEmpty {
                    viewModel.loadQuotes()
                }
            }
        }
    }

    func shareQuote(_ quote: Quote) {
        let quoteText = "“\(quote.text)” — \(quote.author)"
        let av = UIActivityViewController(activityItems: [quoteText], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(av, animated: true, completion: nil)
        }
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
