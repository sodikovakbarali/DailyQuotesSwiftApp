import Foundation

struct Quote: Identifiable, Codable, Equatable {
    var id = UUID()
    let text: String
    let author: String
}
