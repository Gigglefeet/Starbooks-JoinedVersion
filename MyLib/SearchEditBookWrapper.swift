import SwiftUI

struct SearchEditBookWrapper: View {
    let book: Book
    let updateBookAction: (Book) -> Void
    let onDismiss: () -> Void
    
    @State private var editableBook: Book
    
    init(book: Book, updateBookAction: @escaping (Book) -> Void, onDismiss: @escaping () -> Void) {
        self.book = book
        self.updateBookAction = updateBookAction
        self.onDismiss = onDismiss
        self._editableBook = State(initialValue: book)
    }
    
    var body: some View {
        EditBookView(book: $editableBook)
            .onDisappear {
                // Update the book in the data store when the edit view disappears
                if editableBook != book {
                    updateBookAction(editableBook)
                }
                onDismiss()
            }
    }
} 