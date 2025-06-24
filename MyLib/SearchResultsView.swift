import SwiftUI

struct SearchResultsView: View {
    let searchResults: (wishlist: [Book], hangar: [Book], archives: [Book])
    let selectedFilter: FilterOption
    
    // Action closures
    let markAsReadAction: (Book) -> Void
    let moveToHangarFromWishlist: (Book) -> Void
    let moveToHangarFromArchives: (Book) -> Void
    let moveFromHangarToArchives: (Book) -> Void
    let setRatingAction: (Book, Int) -> Void
    let setHangarRating: (Book, Int) -> Void
    let markAsUnreadAction: (Book) -> Void
    let moveFromHangarToWishlist: (Book) -> Void
    let updateBookAction: (Book) -> Void
    
    @State private var bookToEdit: Book? = nil
    
    private var totalResults: Int {
        searchResults.wishlist.count + searchResults.hangar.count + searchResults.archives.count
    }
    
    var body: some View {
        List {
            if totalResults == 0 {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No books found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Try searching for a different title, author, or keyword")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else {
                // Wishlist Results
                if !searchResults.wishlist.isEmpty {
                    Section(header: Text("Jedi-Wishlist (\(searchResults.wishlist.count))")) {
                        ForEach(searchResults.wishlist) { book in
                            WishlistBookRowView(
                                book: book,
                                markAsReadAction: markAsReadAction,
                                moveToHangarAction: moveToHangarFromWishlist,
                                bookToEdit: $bookToEdit
                            )
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                
                // Hangar Results
                if !searchResults.hangar.isEmpty {
                    Section(header: Text("In The Hangar (\(searchResults.hangar.count))")) {
                        ForEach(searchResults.hangar) { book in
                            HangarBookRowView(
                                book: book,
                                moveFromHangarToArchivesAction: moveFromHangarToArchives,
                                setHangarRatingAction: setHangarRating,
                                moveFromHangarToWishlistAction: moveFromHangarToWishlist,
                                bookToEdit: $bookToEdit
                            )
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                
                // Archives Results
                if !searchResults.archives.isEmpty {
                    Section(header: Text("Empire-Archives (\(searchResults.archives.count))")) {
                        ForEach(searchResults.archives) { book in
                            ArchiveBookRowView(
                                book: book,
                                setRatingAction: setRatingAction,
                                markAsUnreadAction: markAsUnreadAction,
                                moveToHangarAction: moveToHangarFromArchives,
                                bookToEdit: $bookToEdit
                            )
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                
                // Search summary
                Section {
                    VStack(spacing: 4) {
                        HStack {
                            Spacer()
                            Text("Found \(totalResults) book\(totalResults == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                        if selectedFilter != .all {
                            HStack {
                                Spacer()
                                Text("Filter: \(selectedFilter.rawValue)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .opacity(0.8)
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .background(
            StarfieldView(starCount: 100)
                .edgesIgnoringSafeArea(.all)
        )
        .sheet(item: $bookToEdit) { book in
            SearchEditBookWrapper(
                book: book,
                updateBookAction: updateBookAction,
                onDismiss: { bookToEdit = nil }
            )
            .environment(\.colorScheme, .dark)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Search Results")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.black.opacity(0.6)))
            }
        }
    }
} 