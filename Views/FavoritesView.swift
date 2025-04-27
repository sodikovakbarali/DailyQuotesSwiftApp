import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: QuoteViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.favorites) { quote in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("“\(quote.text)”")
                            .font(.body)
                        Text("- \(quote.author)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: delete)
            }
            .navigationBarTitle("Favorites")
            .toolbar {
                EditButton()
            }
        }
    }

    func delete(at offsets: IndexSet) {
        for index in offsets {
            viewModel.unfavorite(quote: viewModel.favorites[index])
        }
    }
}
