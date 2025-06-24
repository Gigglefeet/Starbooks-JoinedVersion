import SwiftUI

struct MainContentView: View {
    @ObservedObject var dataStore: DataStore
    @Binding var showingAddBookSheet: Bool
    
    // Action closures
    let markAsRead: (Book) -> Void
    let moveToHangarFromWishlist: (Book) -> Void
    let moveToHangarFromArchives: (Book) -> Void
    let moveFromHangarToArchives: (Book) -> Void
    let setRating: (Book, Int) -> Void
    let setHangarRating: (Book, Int) -> Void
    let reorderHangar: (IndexSet, Int) -> Void
    let moveFromHangarToWishlist: (Book) -> Void
    let deleteFromHangar: (IndexSet) -> Void
    let deleteBookFromHangar: (Book) -> Void
    let deleteFromWishlist: (IndexSet) -> Void
    let reorderWishlist: (IndexSet, Int) -> Void
    let markAsUnreadAction: (Book) -> Void
    let reorderArchives: (IndexSet, Int) -> Void
    let deleteFromArchives: (IndexSet) -> Void
    
    var body: some View {
        VStack { // Main content VStack with starfield background
            Spacer()

            // Top Row: Wishlist and Archives side-by-side
            HStack {
                Spacer() // Center the HStack contents

                // Navigation Link for Wishlist
                NavigationLink {
                     HolocronWishlistView(
                         holocronWishlist: $dataStore.holocronWishlist, // Use DataStore
                         markAsReadAction: markAsRead,
                         moveToHangarAction: moveToHangarFromWishlist, // Pass new action
                         deleteAction: deleteFromWishlist, // Pass delete function
                         reorderWishlist: reorderWishlist // Pass reordering function
                     )
                     .navigationHyperspaceEffect() // Apply our custom transition effect
                } label: { // Rebel Logo + Text Label
                    VStack {
                        Image("rebel_logo")
                            .resizable().aspectRatio(contentMode: .fit).frame(width: 100, height: 100)
                        Text("Jedi-Wishlist")
                             .font(.footnote).fontWeight(.bold).foregroundColor(.white)
                             .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                    }
                    .padding()
                }

                Spacer() // Add space between the two top buttons

                // Navigation Link for Archives
                NavigationLink {
                    JediArchivesView(
                        jediArchives: $dataStore.jediArchives, // Use DataStore
                        setRatingAction: setRating,
                        markAsUnreadAction: markAsUnreadAction, // Keep existing action
                        moveToHangarAction: moveToHangarFromArchives, // Pass new action
                        reorderArchives: reorderArchives, // Pass reordering function
                        deleteAction: deleteFromArchives // Pass delete function
                    )
                    .navigationHyperspaceEffect() // Apply our custom transition effect
                } label: { // Empire Logo + Text Label
                     VStack {
                        Image("empire_logo")
                            .resizable().aspectRatio(contentMode: .fit).frame(width: 100, height: 100)
                        Text("Empire-Archives")
                             .font(.footnote).fontWeight(.bold).foregroundColor(.white)
                             .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                    }
                     .padding()
                }

                Spacer() // Center the HStack contents
            } // End of Top HStack

            Spacer() // Push Hangar button down

            // Middle Row: Hangar button
            NavigationLink {
                // Destination will be HangarView (created in Phase 4)
                // Pass all required bindings and actions
                 HangarView(
                     inTheHangar: $dataStore.inTheHangar,
                     moveFromHangarToArchives: moveFromHangarToArchives,
                     setHangarRating: setHangarRating,
                     reorderHangar: reorderHangar,
                     moveToHangarFromWishlist: moveToHangarFromWishlist,
                     moveFromHangarToWishlist: moveFromHangarToWishlist,
                     deleteFromHangar: deleteFromHangar,
                     deleteBookFromHangar: deleteBookFromHangar,
                     wishlist: $dataStore.holocronWishlist
                 )
                 .navigationHyperspaceEffect() // Apply our custom transition effect
            } label: {
                VStack {
                    // Placeholder for Millennium Falcon
                    Image("falcon_logo") // Use custom logo
                         .resizable().aspectRatio(contentMode: .fit).frame(width: 100, height: 100)
                    Text("In The Hangar")
                        .font(.footnote).fontWeight(.bold).foregroundColor(.white)
                        .shadow(color: .black.opacity(0.7), radius: 2, x: 1, y: 1)
                }
                .padding()
            }

            Spacer() // Push Add button down

            // Bottom Row: Death Star Button to add books
            Button {
                showingAddBookSheet = true
            } label: {
                Image("death_star_icon")
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 80, height: 80)
                    .padding(.bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background( // Replace static starfield with animated one
            StarfieldView(starCount: 150)
                .edgesIgnoringSafeArea(.all)
                .transition(AnyTransition.opacity.combined(with: .scale))
        )
        .sheet(isPresented: $showingAddBookSheet) { // Sheet to present AddBookView
             AddBookView { newBook in
                 dataStore.holocronWishlist.append(newBook) // Add to DataStore
             }
             .environment(\.colorScheme, .dark)
        }
        .toolbar { // Custom centered title
            ToolbarItem(placement: .principal) {
                Text("StarBooks Command")
                    .font(.headline).foregroundColor(.white)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Capsule().fill(Color.black.opacity(0.6)))
            }
        }
    }
} 