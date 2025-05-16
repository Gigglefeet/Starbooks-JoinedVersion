import SwiftUI

// MARK: - Row View Definition
struct HangarBookRowView: View {
    // Data & Actions
    let book: Book
    var moveFromHangarToArchivesAction: (Book) -> Void
    var setHangarRatingAction: (Book, Int) -> Void
    var moveFromHangarToWishlistAction: (Book) -> Void // For context menu
    @Binding var bookToEdit: Book?

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.body).foregroundColor(.white)
                    .shadow(color: .black.opacity(0.7), radius: 1, x: 0, y: 1)
                Text(book.author)
                    .font(.caption).foregroundColor(.gray)
                    .shadow(color: .black.opacity(0.7), radius: 1, x: 0, y: 1)

                // Notes Preview
                if !book.notes.isEmpty {
                    Text(book.notes)
                        .font(.footnote).foregroundColor(.secondary).lineLimit(1).padding(.top, 1)
                }
            }

            Spacer() // Push rating stars to the right
            
            // Interactive Lightsaber Ratings
            HStack(spacing: 2) { // Consistent spacing with ArchiveRow
                ForEach(1...5, id: \.self) { starIndex in
                    LightsaberView(
                        isLit: starIndex <= book.rating,
                        color: LightsaberView.colorForIndex(starIndex),
                        size: .caption // Or .small based on visual preference
                    )
                    .onTapGesture {
                        let newRating = (starIndex == book.rating) ? 0 : starIndex
                        setHangarRatingAction(book, newRating)
                    }
                }
            }
        } // End of Row HStack
        .padding(.vertical, 4) // Add vertical padding for visual separation
        .contentShape(Rectangle()) // Make entire row tappable for editing
        .onTapGesture {
            self.bookToEdit = book
        }
        .listRowBackground(Color.clear) // Keep background transparent
        // Context menu for all actions (available on long press)
        .contextMenu {
            Button {
                moveFromHangarToArchivesAction(book)
            } label: {
                Label("Mark as Finished", image: "empire_logo") // Empire for Archives
            }
            
            Button {
                moveFromHangarToWishlistAction(book)
            } label: {
                Label("Send to Wishlist", image: "rebel_logo") // Rebel for Wishlist
            }
        }
        // Swipe Action: Move to Archives (Finished Reading) - Leading Edge (Swipe Right)
        .swipeActions(edge: .leading, allowsFullSwipe: true) { // Allow full swipe
            Button {
                moveFromHangarToArchivesAction(book)
            } label: {
                Label("Finished", systemImage: "checkmark.circle.fill")
            }
            .tint(.green)
        }
        // No default trailing swipe, but context menu offers move to wishlist
    }
}

// MARK: - Preview
#Preview {
    struct HangarRowPreviewWrapper: View {
        @State var sampleBookCurrentlyReading = Book(title: "Hyperspace Navigation", author: "Corellian Engineering Corp", notes: "Chapter 3 is tricky.", rating: 3)
        @State var anotherBook = Book(title: "Droid Maintenance 101", author: "Industrial Automaton", rating: 0)
        @State var editingBook: Book? = nil

        func previewMoveToArchives(book: Book) { print("PREVIEW HANGAR ROW: Move '\(book.title)' to Archives. Rating: \(book.rating)") }
        func previewSetRating(book: Book, rating: Int) {
            if book.id == sampleBookCurrentlyReading.id {
                sampleBookCurrentlyReading.rating = rating
            } else if book.id == anotherBook.id {
                anotherBook.rating = rating
            }
            print("PREVIEW HANGAR ROW: Set rating for '\(book.title)' to \(rating)")
        }
        func previewMoveToWishlist(book: Book) { print("PREVIEW HANGAR ROW: Move '\(book.title)' to Wishlist.")}

        var body: some View {
            List {
                HangarBookRowView(
                    book: sampleBookCurrentlyReading,
                    moveFromHangarToArchivesAction: previewMoveToArchives,
                    setHangarRatingAction: previewSetRating,
                    moveFromHangarToWishlistAction: previewMoveToWishlist,
                    bookToEdit: $editingBook
                )
                HangarBookRowView(
                    book: anotherBook,
                    moveFromHangarToArchivesAction: previewMoveToArchives,
                    setHangarRatingAction: previewSetRating,
                    moveFromHangarToWishlistAction: previewMoveToWishlist,
                    bookToEdit: $editingBook
                )
            }
            .environment(\.colorScheme, .dark)
            .sheet(item: $editingBook) { bookToEdit in
                 Text("Editing '\(bookToEdit.title)' in Hangar Preview")
                     .padding()
            }
        }
    }
    return HangarRowPreviewWrapper()
}
