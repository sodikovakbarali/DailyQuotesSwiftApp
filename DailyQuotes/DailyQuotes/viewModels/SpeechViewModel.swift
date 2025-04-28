import Foundation
import AVFoundation
import SwiftUI
import Combine

class SpeechViewModel: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    @Published var isSpeaking: Bool = false
    @Published var currentVoiceIdentifier: String?
    @Published var audioLevel: CGFloat = 0.0
    @Published var availableVoices: [Voice] = []
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    private var audioLevelTimer: Timer?
    
    override init() {
        super.init()
        speechSynthesizer.delegate = self
        loadAvailableVoices()
        
        // Select default voice
        if let defaultVoice = availableVoices.first {
            currentVoiceIdentifier = defaultVoice.identifier
        }
    }
    
    deinit {
        stopSpeaking()
        audioLevelTimer?.invalidate()
    }
    
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
            self.startAudioLevelAnimation()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.stopAudioLevelAnimation()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
            self.stopAudioLevelAnimation()
        }
    }
    
    func loadAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // Filter voices - use only English and Russian high-quality voices
        availableVoices = voices
            .filter { voice in
                let language = voice.language
                return (language.contains("en") || language.contains("ru")) && voice.quality == .enhanced
            }
            .map { voice in
                let name = voice.name
                    .replacingOccurrences(of: "com.apple.speech.synthesis.voice.", with: "")
                    .replacingOccurrences(of: "com.apple.voice.enhanced.", with: "")
                    .replacingOccurrences(of: "com.apple.voice.premium.", with: "")
                    .capitalized
                
                return Voice(
                    identifier: voice.identifier,
                    name: name,
                    gender: name.contains("Fiona") || name.contains("Samantha") || name.contains("Catherine") ? .female : .male,
                    language: voice.language
                )
            }
            .sorted { $0.name < $1.name }
    }
    
    func speakQuote(text: String, author: String) {
        // Stop previous speech if any
        if isSpeaking {
            stopSpeaking()
        }
        
        // Create full text for speech
        let fullText = "\(text), by \(author)"
        
        let utterance = AVSpeechUtterance(string: fullText)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // If a specific voice is selected, use it
        if let voiceIdentifier = currentVoiceIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            // Otherwise use default voice for English
            utterance.voice = voice
        }
        
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    func selectVoice(identifier: String) {
        self.currentVoiceIdentifier = identifier
    }
    
    // Audio level animation for visual effect
    private func startAudioLevelAnimation() {
        audioLevelTimer?.invalidate()
        
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.audioLevel = CGFloat.random(in: 0.2...1.0)
            }
        }
    }
    
    private func stopAudioLevelAnimation() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
        audioLevel = 0.0
    }
}

// Voice model for user interface
struct Voice: Identifiable {
    var id: String { identifier }
    let identifier: String
    let name: String
    let gender: Gender
    let language: String
    
    enum Gender {
        case male, female
    }
    
    var iconName: String {
        switch gender {
        case .male:
            return "person.fill"
        case .female:
            return "person.fill"
        }
    }
} 