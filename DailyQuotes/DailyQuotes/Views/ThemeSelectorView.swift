import SwiftUI

struct ThemeSelectorView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Theme selection
                    VStack(alignment: .leading) {
                        Text("Choose Theme")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.availableThemes) { theme in
                            ThemeRow(theme: theme, isSelected: theme.id == viewModel.currentTheme.id)
                                .onTapGesture {
                                    viewModel.setTheme(theme)
                                }
                        }
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    // Animation selection
                    VStack(alignment: .leading) {
                        Text("Choose Animation")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(QuoteViewModel.AnimationMode.allCases) { mode in
                            AnimationRow(mode: mode, isSelected: mode == viewModel.animationMode)
                                .onTapGesture {
                                    viewModel.setAnimationMode(mode)
                                }
                        }
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    // Voice settings
                    VStack(alignment: .leading) {
                        Text("Voice Settings")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Button(action: {
                            // Close the current window
                            presentationMode.wrappedValue.dismiss()
                            // Small delay before opening the new window
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                viewModel.showVoiceSelector = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "person.wave.2.fill")
                                    .font(.title2)
                                
                                Text("Choose Voice")
                                    .font(.body)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.gray.opacity(0.1))
                            )
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical)
                    
                    // Preview
                    VStack(alignment: .leading) {
                        Text("Preview")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if !viewModel.quotes.isEmpty {
                            AnimatedQuoteCard(
                                quote: viewModel.quotes[viewModel.currentIndex],
                                theme: viewModel.currentTheme,
                                animationMode: viewModel.animationMode,
                                speechViewModel: viewModel.speechViewModel
                            )
                            .id("preview-quote")
                        }
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            .navigationBarTitle("Customization", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ThemeRow: View {
    let theme: Theme
    let isSelected: Bool
    
    var body: some View {
        HStack {
            // Color circles
            HStack(spacing: 8) {
                Circle()
                    .fill(theme.primaryColorValue)
                    .frame(width: 20, height: 20)
                
                Circle()
                    .fill(theme.secondaryColorValue)
                    .frame(width: 20, height: 20)
                
                Circle()
                    .fill(theme.textColorValue)
                    .frame(width: 20, height: 20)
            }
            
            Text(theme.name)
                .font(.body)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

struct AnimationRow: View {
    let mode: QuoteViewModel.AnimationMode
    let isSelected: Bool
    
    var body: some View {
        HStack {
            // Animation icon
            Image(systemName: iconForMode(mode))
                .font(.title2)
            
            Text(mode.rawValue)
                .font(.body)
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    private func iconForMode(_ mode: QuoteViewModel.AnimationMode) -> String {
        switch mode {
        case .none:
            return "rectangle"
        case .fade:
            return "rectangle.portrait.on.rectangle.portrait"
        case .slide:
            return "arrow.left.and.right.square"
        case .flip:
            return "arrow.triangle.2.circlepath"
        case .zoom:
            return "arrow.up.left.and.arrow.down.right"
        }
    }
} 