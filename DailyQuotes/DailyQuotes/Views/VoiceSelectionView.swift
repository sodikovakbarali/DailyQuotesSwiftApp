import SwiftUI

struct VoiceSelectionView: View {
    @ObservedObject var speechViewModel: SpeechViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Choose Voice")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if speechViewModel.availableVoices.isEmpty {
                        Text("No enhanced voices available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // First display English voices
                        voiceList(for: "en")
                        
                        // Then display Russian voices if they are available
                        voiceList(for: "ru")
                    }
                }
                .padding()
            }
            .navigationBarTitle("Voice Selection", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    @ViewBuilder
    private func voiceList(for languagePrefix: String) -> some View {
        let filteredVoices = speechViewModel.availableVoices.filter { $0.language.hasPrefix(languagePrefix) }
        
        if !filteredVoices.isEmpty {
            // Language name header
            Text(languagePrefix == "en" ? "English" : "Russian")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .padding(.top, 10)
            
            ForEach(filteredVoices) { voice in
                VoiceRow(
                    voice: voice,
                    isSelected: voice.identifier == speechViewModel.currentVoiceIdentifier,
                    action: {
                        speechViewModel.selectVoice(identifier: voice.identifier)
                    }
                )
            }
        }
    }
}

struct VoiceRow: View {
    let voice: Voice
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                // Voice icon
                Image(systemName: voice.gender == .male ? "person.circle.fill" : "person.circle")
                    .font(.title2)
                    .foregroundColor(voice.gender == .male ? .blue : .purple)
                
                VStack(alignment: .leading) {
                    Text(voice.name)
                        .font(.body)
                    
                    Text(formatLanguage(voice.language))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
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
        .buttonStyle(PlainButtonStyle())
    }
    
    // Formats the language code in a more readable format
    private func formatLanguage(_ language: String) -> String {
        if language.hasPrefix("en") {
            return "English (\(language))"
        } else if language.hasPrefix("ru") {
            return "Russian (\(language))"
        }
        return language
    }
}

struct VoiceSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceSelectionView(speechViewModel: SpeechViewModel())
    }
} 