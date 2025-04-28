import SwiftUI

struct AnimatedQuoteCard: View {
    let quote: Quote
    let theme: Theme
    let animationMode: QuoteViewModel.AnimationMode
    let speechViewModel: SpeechViewModel
    @State private var isAnimating = false
    
    // ID for tracking quote changes
    private let id = UUID()
    
    init(quote: Quote, theme: Theme, animationMode: QuoteViewModel.AnimationMode, speechViewModel: SpeechViewModel) {
        self.quote = quote
        self.theme = theme
        self.animationMode = animationMode
        self.speechViewModel = speechViewModel
    }
    
    var body: some View {
        VStack {
            Text("\"\(quote.text)\"")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                .padding()
                .foregroundColor(theme.textColorValue)
            
            Text("- \(quote.author)")
                .font(.subheadline)
                .foregroundColor(theme.textColorValue.opacity(0.8))
                .padding(.top, 5)
            
            // Add AudioWaveView when the quote is being spoken
            if speechViewModel.isSpeaking {
                AudioWaveView(
                    audioLevel: Binding<CGFloat>(
                        get: { speechViewModel.audioLevel },
                        set: { speechViewModel.audioLevel = $0 }
                    ),
                    barCount: 12,
                    spacing: 4,
                    color: theme.primaryColorValue
                )
                .frame(height: 40)
                .padding(.top, 15)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(theme.secondaryColorValue.opacity(0.9))
                    .shadow(radius: 10)
                
                if let backgroundImage = theme.backgroundImage,
                   let uiImage = UIImage(named: backgroundImage) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .opacity(0.3)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
            }
        )
        .padding(.horizontal)
        .modifier(AnimationModifier(mode: animationMode, isAnimating: isAnimating))
        .onAppear {
            withAnimation(.spring()) {
                isAnimating = true
            }
        }
        .id(quote.id) // Use the quote ID for identification
        .onDisappear {
            isAnimating = false
        }
        .onChange(of: quote.id) { _ in
            // Reset the animation when the quote changes
            isAnimating = false
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
        .animation(.spring(), value: speechViewModel.isSpeaking)
    }
}

struct AnimationModifier: ViewModifier {
    let mode: QuoteViewModel.AnimationMode
    let isAnimating: Bool
    
    func body(content: Content) -> some View {
        switch mode {
        case .none:
            content
            
        case .fade:
            content
                .opacity(isAnimating ? 1 : 0)
            
        case .slide:
            content
                .offset(x: isAnimating ? 0 : -UIScreen.main.bounds.width)
            
        case .flip:
            content
                .rotation3DEffect(
                    .degrees(isAnimating ? 0 : 180),
                    axis: (x: 0, y: 1, z: 0)
                )
            
        case .zoom:
            content
                .scaleEffect(isAnimating ? 1 : 0.5)
                .opacity(isAnimating ? 1 : 0)
        }
    }
}

// Preview
struct AnimatedQuoteCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            AnimatedQuoteCard(
                quote: Quote(text: "The best way to get started is to quit talking and begin doing.", author: "Walt Disney"),
                theme: Theme.presets[0],
                animationMode: .fade,
                speechViewModel: SpeechViewModel()
            )
            
            AnimatedQuoteCard(
                quote: Quote(text: "Success is not in what you have, but who you are.", author: "Bo Bennett"),
                theme: Theme.presets[2],
                animationMode: .slide,
                speechViewModel: SpeechViewModel()
            )
        }
    }
}
