import SwiftUI

// Widok dolnego paska nawigacji z trzema zakładkami
struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Katalog", systemImage: "gamecontroller")
                }
            CustomGamesView()
                .tabItem {
                    Label("Własne gry", systemImage: "person.crop.square")
                }
            FavoritesView()
                .tabItem {
                    Label("Ulubione", systemImage: "heart.fill")
                }
        }
    }
}
