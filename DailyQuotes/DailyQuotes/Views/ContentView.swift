import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = QuoteViewModel()
    @State private var showFavorites = false
    @State private var showImageGenerator = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Фоновый градиент или изображение
                backgroundView
                
                VStack {
                    if !viewModel.quotes.isEmpty {
                        // Анимированная карточка цитаты
                        AnimatedQuoteCard(
                            quote: viewModel.quotes[viewModel.currentIndex],
                            theme: viewModel.currentTheme,
                            animationMode: viewModel.animationMode,
                            speechViewModel: viewModel.speechViewModel
                        )
                        // Используем сам индекс для идентификации вместо ID цитаты
                        .id("quote-\(viewModel.currentIndex)")
                        
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
                        
                        // Элементы управления для озвучивания
                        HStack(spacing: 10) {
                            Button(action: {
                                if viewModel.speechViewModel.isSpeaking {
                                    viewModel.stopSpeaking()
                                } else {
                                    viewModel.speakCurrentQuote()
                                }
                            }) {
                                Image(systemName: viewModel.speechViewModel.isSpeaking ? "stop.fill" : "play.fill")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(viewModel.currentTheme.primaryColorValue)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Button(action: {
                                viewModel.showVoiceSelector = true
                            }) {
                                Image(systemName: "person.wave.2.fill")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(viewModel.currentTheme.primaryColorValue.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                            
                            Button(action: {
                                showImageGenerator = true
                            }) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(viewModel.currentTheme.primaryColorValue.opacity(0.8))
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        .padding(.top, 10)
                        
                        // Элементы управления
                        HStack(spacing: 20) {
                            // Кнопка предыдущей цитаты
                            Button(action: viewModel.previousQuote) {
                                Image(systemName: "arrow.left.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(viewModel.currentTheme.primaryColorValue)
                            }
                            .disabled(viewModel.currentIndex == 0)
                            
                            // Кнопка случайной цитаты
                            Button(action: viewModel.randomQuote) {
                                Image(systemName: "shuffle.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(viewModel.currentTheme.primaryColorValue)
                            }
                            
                            // Кнопка добавления в избранное
                            Button(action: {
                                viewModel.favoriteCurrentQuote()
                            }) {
                                Image(systemName: viewModel.isFavorite(viewModel.quotes[viewModel.currentIndex]) ? "heart.fill" : "heart")
                                    .font(.largeTitle)
                                    .foregroundColor(viewModel.isFavorite(viewModel.quotes[viewModel.currentIndex]) ? .red : viewModel.currentTheme.primaryColorValue)
                            }
                            
                            // Кнопка следующей цитаты
                            Button(action: {
                                viewModel.nextQuote()
                            }) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(viewModel.currentTheme.primaryColorValue)
                            }
                            .disabled(viewModel.currentIndex >= viewModel.quotes.count - 1)
                            
                            // Кнопка шаринга
                            Button(action: {
                                shareQuote(viewModel.quotes[viewModel.currentIndex])
                            }) {
                                Image(systemName: "square.and.arrow.up.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(viewModel.currentTheme.primaryColorValue)
                            }
                        }
                        .padding(.top, 20)
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
                .padding()
            }
            .navigationBarTitle("Daily Quotes", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    viewModel.showThemeSelector = true
                }) {
                    Image(systemName: "paintbrush.fill")
                },
                trailing: Button("Favorites") {
                    showFavorites = true
                }
            )
            .sheet(isPresented: $showFavorites) {
                FavoritesView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showThemeSelector) {
                ThemeSelectorView(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.showVoiceSelector) {
                VoiceSelectionView(speechViewModel: viewModel.speechViewModel)
            }
            .sheet(isPresented: $showImageGenerator) {
                QuoteImageGeneratorView(quoteViewModel: viewModel)
            }
            .onAppear {
                // If the quotes are not loaded at the first launch, reload them
                if viewModel.quotes.isEmpty {
                    viewModel.loadQuotes()
                }
            }
            .onDisappear {
                // Останавливаем озвучивание при закрытии экрана
                viewModel.stopSpeaking()
            }
        }
    }
    
    // Создаем фоновое представление в зависимости от выбранной темы
    var backgroundView: some View {
        ZStack {
            // Основной цвет
            viewModel.currentTheme.primaryColorValue
                .opacity(0.2)
                .ignoresSafeArea()
            
            // Фоновое изображение, если есть
            if let backgroundImage = viewModel.currentTheme.backgroundImage,
               let uiImage = UIImage(named: backgroundImage) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.1)
                    .ignoresSafeArea()
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
