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
        
        // Выбираем голос по умолчанию
        if let defaultVoice = availableVoices.first {
            currentVoiceIdentifier = defaultVoice.identifier
        }
    }
    
    deinit {
        stopSpeaking()
        audioLevelTimer?.invalidate()
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
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
    
    // MARK: - Public Methods
    
    func loadAvailableVoices() {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        
        // Фильтруем голоса - берем только английские и русские голоса высокого качества
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
        // Останавливаем предыдущую речь, если есть
        if isSpeaking {
            stopSpeaking()
        }
        
        // Создаем полный текст для озвучивания
        let fullText = "\(text), by \(author)"
        
        let utterance = AVSpeechUtterance(string: fullText)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        // Если выбран конкретный голос, используем его
        if let voiceIdentifier = currentVoiceIdentifier,
           let voice = AVSpeechSynthesisVoice(identifier: voiceIdentifier) {
            utterance.voice = voice
        } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            // Иначе используем голос по умолчанию для английского
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
    
    // MARK: - Private Methods
    
    // Анимация уровня звука для визуального эффекта
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

// Модель голоса для пользовательского интерфейса
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