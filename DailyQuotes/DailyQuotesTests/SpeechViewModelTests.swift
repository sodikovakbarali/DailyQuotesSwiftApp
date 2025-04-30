import XCTest
@testable import DailyQuotes

final class SpeechViewModelTests: XCTestCase {
    var viewModel: SpeechViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = SpeechViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertFalse(viewModel.isSpeaking)
        XCTAssertNotNil(viewModel.currentVoiceIdentifier)
        XCTAssertEqual(viewModel.audioLevel, 0.0)
        XCTAssertFalse(viewModel.availableVoices.isEmpty)
    }
    
    func testSpeakQuote() {
        let quote = Quote(text: "Test quote", author: "Test Author")
        
        viewModel.speakQuote(text: quote.text, author: quote.author)
        XCTAssertTrue(viewModel.isSpeaking)
        
        viewModel.stopSpeaking()
        XCTAssertFalse(viewModel.isSpeaking)
    }
    
    func testStopSpeaking() {
        let quote = Quote(text: "Test quote", author: "Test Author")
        
        viewModel.speakQuote(text: quote.text, author: quote.author)
        viewModel.stopSpeaking()
        
        XCTAssertFalse(viewModel.isSpeaking)
    }
    
    func testAudioLevelAnimation() {
        let quote = Quote(text: "Test quote", author: "Test Author")
        
        viewModel.speakQuote(text: quote.text, author: quote.author)
        XCTAssertTrue(viewModel.isSpeaking)
        XCTAssertGreaterThan(viewModel.audioLevel, 0.0)
        
        viewModel.stopSpeaking()
        XCTAssertEqual(viewModel.audioLevel, 0.0)
    }
    
    func testVoiceSelection() {
        let initialVoice = viewModel.currentVoiceIdentifier
        let newVoice = viewModel.availableVoices[1].identifier
        
        viewModel.selectVoice(identifier: newVoice)
        XCTAssertEqual(viewModel.currentVoiceIdentifier, newVoice)
        XCTAssertNotEqual(viewModel.currentVoiceIdentifier, initialVoice)
    }
} 
