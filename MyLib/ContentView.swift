import SwiftUI

struct ContentView: View {
    // StateObject to manage the data store
    @StateObject private var dataStore = DataStore()

    // State for presenting the add book sheet
    @State private var showingAddBookSheet = false
    
    // Search and filter state
    @State private var searchText = ""
    @State private var showingSearchResults = false
    @State private var selectedFilter: FilterOption = .all
    @State private var showingFilterMenu = false
    
    // Achievement notifications
    @State private var showingAchievementToast = false
    @State private var currentAchievement: ReadingAchievement?
    
    // Computed property for search results across all sections
    var searchResults: (wishlist: [Book], hangar: [Book], archives: [Book]) {
        if searchText.isEmpty {
            return ([], [], [])
        }
        
        let filteredWishlist = dataStore.holocronWishlist
            .filtered(by: selectedFilter)
            .filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText) ||
                book.notes.localizedCaseInsensitiveContains(searchText)
            }
        
        let filteredHangar = dataStore.inTheHangar
            .filtered(by: selectedFilter)
            .filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText) ||
                book.notes.localizedCaseInsensitiveContains(searchText)
            }
        
        let filteredArchives = dataStore.jediArchives
            .filtered(by: selectedFilter)
            .filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText) ||
                book.notes.localizedCaseInsensitiveContains(searchText)
            }
        
        return (filteredWishlist, filteredHangar, filteredArchives)
    }

    var body: some View {
        NavigationView {
            Group {
                if !searchText.isEmpty {
                    SearchResultsView(
                        searchResults: searchResults,
                        selectedFilter: selectedFilter,
                        markAsReadAction: markAsRead,
                        moveToHangarFromWishlist: moveToHangarFromWishlist,
                        moveToHangarFromArchives: moveToHangarFromArchives,
                        moveFromHangarToArchives: moveFromHangarToArchives,
                        setRatingAction: setRating,
                        setHangarRating: setHangarRating,
                        markAsUnreadAction: markAsUnread,
                        moveFromHangarToWishlist: moveFromHangarToWishlist,
                        updateBookAction: updateBook
                    )
                } else {
                    MainContentView(
                        dataStore: dataStore,
                        showingAddBookSheet: $showingAddBookSheet,
                        markAsRead: markAsRead,
                        moveToHangarFromWishlist: moveToHangarFromWishlist,
                        moveToHangarFromArchives: moveToHangarFromArchives,
                        moveFromHangarToArchives: moveFromHangarToArchives,
                        setRating: setRating,
                        setHangarRating: setHangarRating,
                        reorderHangar: reorderHangar,
                        moveFromHangarToWishlist: moveFromHangarToWishlist,
                        deleteFromHangar: deleteFromHangar,
                        deleteBookFromHangar: deleteBookFromHangar,
                        deleteFromWishlist: deleteFromWishlist,
                        reorderWishlist: reorderWishlist,
                        markAsUnreadAction: markAsUnread,
                        reorderArchives: reorderArchives,
                        deleteFromArchives: deleteFromArchives
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Search books...")
            .onSubmit(of: .search) {
                showingSearchResults = !searchText.isEmpty
            }
            .onChange(of: searchText) { _, _ in
                showingSearchResults = !searchText.isEmpty
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink {
                        StatsView(statsManager: dataStore.statsManager)
                    } label: {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilterMenu = true
                    } label: {
                        Image(systemName: selectedFilter == .all ? "line.horizontal.3.decrease" : "line.horizontal.3.decrease.circle.fill")
                            .foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text(searchText.isEmpty ? "StarBooks Command" : "Search Results")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.black.opacity(0.6)))
                }
            }
                         .confirmationDialog("Filter Books", isPresented: $showingFilterMenu) {
                 ForEach(FilterOption.allCases, id: \.self) { option in
                     Button(option.rawValue) {
                         selectedFilter = option
                     }
                 }
                 Button("Cancel", role: .cancel) { }
             }
             .overlay(alignment: .top) {
                 if let achievement = currentAchievement {
                     AchievementToastView(
                         achievement: achievement,
                         isShowing: $showingAchievementToast
                     )
                     .padding(.top, 100)
                 }
             }
             .onReceive(dataStore.statsManager.$newAchievements) { achievements in
                 if let newAchievement = achievements.first {
                     currentAchievement = newAchievement
                     withAnimation {
                         showingAchievementToast = true
                     }
                     
                     // Clear the achievement from the manager
                     DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                         dataStore.statsManager.clearNewAchievements()
                     }
                 }
             }
             .onChange(of: showingAchievementToast) { _, isShowing in
                 if !isShowing {
                     currentAchievement = nil
                 }
             }
        }
        .environment(\.colorScheme, .dark) // Apply dark theme globally
        .navigationViewStyle(.stack) // Use stack navigation
        .preferredColorScheme(.dark) // Ensure dark mode for the entire app
    }

    // REMOVED saveData()
    // REMOVED loadData()

    // --- Core Action Functions (now operate on dataStore) ---
    func markAsRead(book: Book) {
        var bookToMove = book
        bookToMove.rating = 0 // Reset rating when moving TO archives
        dataStore.jediArchives.append(bookToMove) // Use DataStore

        if let index = dataStore.holocronWishlist.firstIndex(where: { $0.id == book.id }) { // Use DataStore
            dataStore.holocronWishlist.remove(at: index) // Use DataStore
        } else {
             // print("ERROR markAsRead: Failed to find book in wishlist to remove. Rolling back.")
             dataStore.jediArchives.removeAll(where: { $0.id == book.id}) // Use DataStore
        }
    }

    func setRating(for book: Book, to newRating: Int) {
        if let index = dataStore.jediArchives.firstIndex(where: { $0.id == book.id }) { // Use DataStore
            // Ensure rating is within 0-5 range
            let validatedRating = max(0, min(5, newRating))
            let oldBook = dataStore.jediArchives[index]
            dataStore.jediArchives[index].rating = validatedRating // Use DataStore
            // Track rating stats
            dataStore.statsManager.bookRated(oldBook, rating: validatedRating)
        } else {
             // print("ERROR setRating: Book not found in archives.")
        }
    }

    func markAsUnread(book: Book) {
        // print("DEBUG markAsUnread: Moving ID=\(book.id.uuidString) back to wishlist")
        // Find and remove from archives
        if let index = dataStore.jediArchives.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.jediArchives.remove(at: index)
            // Add back to wishlist (rating is preserved from archives)
            // ** NOTE: This goes to WISHLIST as per clarification **
            dataStore.holocronWishlist.append(bookToMove)
            // print("DEBUG markAsUnread: Move successful.")
        } else {
            // print("ERROR markAsUnread: Book not found in archives to move back.")
        }
    }

    // --- Hangar Action Functions ---

    func moveToHangarFromWishlist(book: Book) {
        if let index = dataStore.holocronWishlist.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.holocronWishlist.remove(at: index)
            dataStore.inTheHangar.append(bookToMove)
            // Track stats
            dataStore.statsManager.bookMovedToHangar(bookToMove)
        } else {
            // print("ERROR moveToHangarFromWishlist: Book not found in wishlist.")
        }
    }

    func moveToHangarFromArchives(book: Book) {
        if let index = dataStore.jediArchives.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.jediArchives.remove(at: index)
            // Rating is preserved when moving from Archives to Hangar
            dataStore.inTheHangar.append(bookToMove)
            // Track stats
            dataStore.statsManager.bookMovedToHangar(bookToMove)
        } else {
            // print("ERROR moveToHangarFromArchives: Book not found in archives.")
        }
    }

    func moveFromHangarToArchives(book: Book) {
        if let index = dataStore.inTheHangar.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.inTheHangar.remove(at: index)
            // Rating is preserved when moving from Hangar to Archives
            dataStore.jediArchives.append(bookToMove)
            // Track stats for book completion
            dataStore.statsManager.bookCompletedFromHangar(bookToMove)
        } else {
            // print("ERROR moveFromHangarToArchives: Book not found in hangar.")
        }
    }

    func setHangarRating(for book: Book, to newRating: Int) {
        if let index = dataStore.inTheHangar.firstIndex(where: { $0.id == book.id }) {
            let validatedRating = max(0, min(5, newRating))
            let oldBook = dataStore.inTheHangar[index]
            dataStore.inTheHangar[index].rating = validatedRating
            // Track rating stats
            dataStore.statsManager.bookRated(oldBook, rating: validatedRating)
        } else {
            // print("ERROR setHangarRating: Book not found in hangar.")
        }
    }

    func reorderHangar(from source: IndexSet, to destination: Int) {
        dataStore.inTheHangar.move(fromOffsets: source, toOffset: destination)
    }

    func moveFromHangarToWishlist(book: Book) {
        if let index = dataStore.inTheHangar.firstIndex(where: { $0.id == book.id }) {
            let bookToMove = dataStore.inTheHangar.remove(at: index)
            // Rating is preserved when moving from Hangar to Wishlist
            dataStore.holocronWishlist.append(bookToMove)
        } else {
            // print("ERROR moveFromHangarToWishlist: Book not found in hangar.")
        }
    }

    // Function to delete books from the hangar
    func deleteFromHangar(at offsets: IndexSet) {
        // print("DEBUG: ContentView.deleteFromHangar - Deleting at offsets: \(offsets)")
        
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            dataStore.inTheHangar.remove(atOffsets: offsets)
            // print("DEBUG: ContentView.deleteFromHangar - Deletion completed. Books after: \(dataStore.inTheHangar.count)")
        }
    }
    
    // Additional function to delete a book by ID
    func deleteBookFromHangar(book: Book) {
        // print("DEBUG: ContentView.deleteBookFromHangar - Attempting to delete book \(book.title) with ID \(book.id)")
        
        // Ensure all UI operations happen on the main thread
        DispatchQueue.main.async {
            // Try to find the book by ID
            if let index = self.dataStore.inTheHangar.firstIndex(where: { $0.id == book.id }) {
                // Use withAnimation(.none) to avoid glitches - fix the unused result warning
                self.dataStore.inTheHangar.remove(at: index)
                // print("DEBUG: ContentView.deleteBookFromHangar - Successfully deleted book at index \(index). Books after: \(self.dataStore.inTheHangar.count)")
            } else {
                // print("ERROR: ContentView.deleteBookFromHangar - Failed to find book ID \(book.id) in hangar for deletion")
                
                // Fallback solution if index can't be found - try to remove by matching a book
                let matchingBooks = self.dataStore.inTheHangar.filter { $0.id == book.id }
                if !matchingBooks.isEmpty {
                    // print("DEBUG: ContentView.deleteBookFromHangar - Attempting alternative deletion method")
                    self.dataStore.inTheHangar.removeAll(where: { $0.id == book.id })
                    // print("DEBUG: ContentView.deleteBookFromHangar - Alternative deletion completed. Books after: \(self.dataStore.inTheHangar.count)")
                }
            }
        }
    }

    // Function for reordering the Wishlist
    func reorderWishlist(from source: IndexSet, to destination: Int) {
        dataStore.holocronWishlist.move(fromOffsets: source, toOffset: destination)
    }
    
    // Function for reordering the Archives
    func reorderArchives(from source: IndexSet, to destination: Int) {
        dataStore.jediArchives.move(fromOffsets: source, toOffset: destination)
    }

    // Function to delete books from the wishlist
    func deleteFromWishlist(at offsets: IndexSet) {
        // print("DEBUG: ContentView.deleteFromWishlist - Deleting at offsets: \(offsets)")
        
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            dataStore.holocronWishlist.remove(atOffsets: offsets)
            // print("DEBUG: ContentView.deleteFromWishlist - Deletion completed. Books after: \(dataStore.holocronWishlist.count)")
        }
    }

    // Function to delete books from the archives
    func deleteFromArchives(at offsets: IndexSet) {
        // print("DEBUG: ContentView.deleteFromArchives - Deleting at offsets: \(offsets)")
        
        // Ensure we're on the main thread
        DispatchQueue.main.async {
            dataStore.jediArchives.remove(atOffsets: offsets)
            // print("DEBUG: ContentView.deleteFromArchives - Deletion completed. Books after: \(dataStore.jediArchives.count)")
        }
    }
    
    // Function to update a book across all sections
    func updateBook(_ updatedBook: Book) {
        // Find and update the book in whichever section it belongs to
        if let index = dataStore.holocronWishlist.firstIndex(where: { $0.id == updatedBook.id }) {
            dataStore.holocronWishlist[index] = updatedBook
        } else if let index = dataStore.inTheHangar.firstIndex(where: { $0.id == updatedBook.id }) {
            dataStore.inTheHangar[index] = updatedBook
        } else if let index = dataStore.jediArchives.firstIndex(where: { $0.id == updatedBook.id }) {
            dataStore.jediArchives[index] = updatedBook
        }
    }
}

// Preview for ContentView - NOTE: May not reflect saved data correctly
#Preview {
    ContentView()
}
