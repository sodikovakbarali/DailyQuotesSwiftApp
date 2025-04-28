import SwiftUI

struct Theme: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let primaryColor: String
    let secondaryColor: String
    let textColor: String
    let backgroundImage: String?
    
    var primaryColorValue: Color {
        Color(hex: primaryColor) ?? .blue
    }
    
    var secondaryColorValue: Color {
        Color(hex: secondaryColor) ?? .white
    }
    
    var textColorValue: Color {
        Color(hex: textColor) ?? .black
    }
    
    static var presets: [Theme] = [
//        Theme(name: "Classic", primaryColor: "#FFFFFF", secondaryColor: "#F0F0F0", textColor: "#000000", backgroundImage: nil),
        Theme(name: "Dark", primaryColor: "#212121", secondaryColor: "#424242", textColor: "#FFFFFF", backgroundImage: nil),
        Theme(name: "Ocean", primaryColor: "#1976D2", secondaryColor: "#64B5F6", textColor: "#FFFFFF", backgroundImage: "ocean"),
        Theme(name: "Sunset", primaryColor: "#FF9800", secondaryColor: "#FFCC80", textColor: "#212121", backgroundImage: "sunset"),
        Theme(name: "Nature", primaryColor: "#4CAF50", secondaryColor: "#A5D6A7", textColor: "#212121", backgroundImage: "nature")
    ]
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
} 
