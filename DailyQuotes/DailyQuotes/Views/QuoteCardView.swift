import SwiftUI

struct QuoteCardView: View {
    let quote: Quote

    var body: some View {
        VStack {
            Text("“\(quote.text)”")
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding()

            Text("- \(quote.author)")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
        .padding()
        .background(Color.white.opacity(0.8))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
    }
}
