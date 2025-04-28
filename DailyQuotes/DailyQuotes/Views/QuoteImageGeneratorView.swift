import SwiftUI

struct QuoteImageGeneratorView: View {
    @ObservedObject var quoteViewModel: QuoteViewModel
    @StateObject private var imageGenerator = ImageGeneratorViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var saveAlertTitle = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Top section - image preview
                ZStack {
                    if let generatedImage = imageGenerator.generatedImage {
                        Image(uiImage: generatedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                            .padding()
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.1))
                            .overlay(
                                VStack {
                                    if imageGenerator.isGenerating {
                                        ProgressView()
                                            .scaleEffect(1.5)
                                            .padding()
                                        
                                        Text("Creating your quote image...")
                                            .font(.headline)
                                    } else {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 60))
                                            .foregroundColor(.gray)
                                            .padding()
                                        
                                        Text("Generate a beautiful image with your quote")
                                            .font(.headline)
                                    }
                                }
                            )
                            .frame(height: 350)
                            .padding()
                    }
                }
                
                // Bottom section - settings and buttons
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Style selection
                        styleSelector
                        
                        // Generation and action buttons
                        actionButtons
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.05))
                .cornerRadius(20)
            }
            .navigationBarTitle("Quote Image", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $imageGenerator.showShareSheet) {
                if let url = imageGenerator.getImageURL() {
                    ShareSheet(items: [url])
                }
            }
            .alert(isPresented: $showSaveAlert) {
                Alert(
                    title: Text(saveAlertTitle),
                    message: Text(saveAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onChange(of: imageGenerator.saveResult) { oldValue, newValue in
                if let result = newValue {
                    switch result {
                    case .success:
                        saveAlertTitle = "Success"
                        saveAlertMessage = "Image saved to your photo library"
                        showSaveAlert = true
                    case .error(let message):
                        saveAlertTitle = "Error"
                        saveAlertMessage = message
                        showSaveAlert = true
                    }
                    // Reset after showing
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        imageGenerator.saveResult = nil
                    }
                }
            }
        }
    }
    
    private var styleSelector: some View {
        VStack(alignment: .leading) {
            Text("Select Style")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ImageGeneratorViewModel.QuoteImageStyle.allCases) { style in
                        StyleCard(style: style, isSelected: style == imageGenerator.selectedStyle)
                            .onTapGesture {
                                imageGenerator.selectedStyle = style
                                if imageGenerator.generatedImage != nil {
                                    // Regenerate image when style changes
                                    generateImage()
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Generate button
            Button(action: generateImage) {
                HStack {
                    Image(systemName: "wand.and.stars")
                    Text("Generate Image")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(quoteViewModel.currentTheme.primaryColorValue)
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
            }
            .disabled(imageGenerator.isGenerating)
            
            if imageGenerator.generatedImage != nil {
                HStack(spacing: 15) {
                    // Save button
                    Button(action: {
                        imageGenerator.saveImageToPhotoLibrary()
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Save")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(quoteViewModel.currentTheme.primaryColorValue)
                        .cornerRadius(12)
                    }
                    
                    // Share button
                    Button(action: {
                        imageGenerator.showShareSheet = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(quoteViewModel.currentTheme.primaryColorValue)
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func generateImage() {
        if !quoteViewModel.quotes.isEmpty {
            imageGenerator.generateQuoteImage(
                quote: quoteViewModel.quotes[quoteViewModel.currentIndex],
                theme: quoteViewModel.currentTheme
            )
        }
    }
}

struct StyleCard: View {
    let style: ImageGeneratorViewModel.QuoteImageStyle
    let isSelected: Bool
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .frame(width: 80, height: 80)
                
                Text("Aa")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
            }
            
            Text(style.rawValue)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                )
        )
        .shadow(radius: isSelected ? 3 : 1)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .modern:
            return Color(UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0))
        case .vintage:
            return Color(UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1.0))
        case .nature:
            return Color(UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0))
        case .minimal:
            return Color(UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0))
        case .gradient:
            return Color(UIColor(red: 0.8, green: 0.3, blue: 0.5, alpha: 1.0))
        }
    }
    
    private var textColor: Color {
        switch style {
        case .modern, .nature, .gradient:
            return .white
        case .vintage:
            return Color(UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0))
        case .minimal:
            return .black
        }
    }
}

// Helper view for sharing
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Preview
struct QuoteImageGeneratorView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteImageGeneratorView(quoteViewModel: QuoteViewModel())
    }
} 