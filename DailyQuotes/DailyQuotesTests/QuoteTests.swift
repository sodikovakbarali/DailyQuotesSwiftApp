import XCTest
@testable import DailyQuotes

final class QuoteTests: XCTestCase {
    
    func testQuoteInitialization() {
        let quote = Quote(text: "Test quote", author: "Test Author")
        
        XCTAssertNotNil(quote.id)
        XCTAssertEqual(quote.text, "Test quote")
        XCTAssertEqual(quote.author, "Test Author")
    }
    
    func testQuoteEquality() {
        let id = UUID()
        let quote1 = Quote(id: id, text: "Test quote", author: "Test Author")
        let quote2 = Quote(id: id, text: "Test quote", author: "Test Author")
        let quote3 = Quote(text: "Different quote", author: "Different Author")
        
        XCTAssertEqual(quote1, quote2)
        XCTAssertNotEqual(quote1, quote3)
    }
    
    func testQuoteCodable() throws {
        let quote = Quote(text: "Test quote", author: "Test Author")
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        let data = try encoder.encode(quote)
        let decodedQuote = try decoder.decode(Quote.self, from: data)
        
        XCTAssertEqual(quote, decodedQuote)
    }
} 