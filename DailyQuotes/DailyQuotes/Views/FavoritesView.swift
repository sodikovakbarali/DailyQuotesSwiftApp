import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        favoriteNavigationView
    }
    
    // Selected main navigation view
    private var favoriteNavigationView: some View {
        NavigationView {
            ZStack {
                // Background view with theme consideration
                viewModel.currentTheme.primaryColorValue
                    .opacity(0.2)
                    .ignoresSafeArea()
                
                favoriteContentView
            }
            .navigationBarTitle("Favorites", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // Selected content - either empty state, or list of quotes
    private var favoriteContentView: some View {
        Group {
            if viewModel.favorites.isEmpty {
                emptyStateView
            } else {
                favoriteListView
            }
        }
    }
    
    // View for the case when there are no favorite quotes
    private var emptyStateView: some View {
        VStack {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            
            Text("No favorite quotes yet")
                .font(.title2)
                .foregroundColor(.gray)
        }
    }
    
    // List of favorite quotes
    private var favoriteListView: some View {
        List {
            ForEach(viewModel.favorites) { quote in
                VStack(alignment: .leading) {
                    Text("\"\(quote.text)\"")
                        .font(.body)
                        .padding(.vertical, 4)
                    
                    Text("- \(quote.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.unfavorite(quote: quote)
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                }
                .listRowBackground(viewModel.currentTheme.secondaryColorValue.opacity(0.2))
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}
