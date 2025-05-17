List {
    WishlistCard(
        book: Book(title: "Card Preview", author: "Card Author", notes: "Card notes", rating: 3),
        moveToHangarAction: { book in
            // print("PREVIEW: Move \(book.title) to hangar")
        }
    )
} 