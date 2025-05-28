import SwiftUI
import CoreData

struct FavoritesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // FetchRequest pobierający ulubione gry (isFavorite == true), posortowane
    @FetchRequest(
        entity: Game.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.title, ascending: true)],
        predicate: NSPredicate(format: "isFavorite == YES")
    ) var favoriteGames: FetchedResults<Game>

    // FetchRequest pobierający wszystkie gatunki, posortowane
    @FetchRequest(
        entity: Genre.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Genre.name, ascending: true)]
    ) var genres: FetchedResults<Genre>

    // Model zarządzający filtrowaniem
    @StateObject private var filterModel = FilterModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Nagłówek widoku z tytułem "Ulubione" i zielonym kolorem
                HeaderView(title: "Ulubione", color: .green)

                // Widok pola wyszukiwania oraz filtrowania po gatunkach
                SearchAndFilterView(
                    genres: Array(genres),
                    searchText: $filterModel.searchText,
                    selectedGenres: $filterModel.selectedGenres,
                    showGenreFilter: $filterModel.showGenreFilter
                )

                // Przefiltrowane gry na podstawie wpisanego tekstu i wybranych gatunków
                let filteredGames = filterModel.filterGames(Array(favoriteGames))

                // Jeśli brak wyników po filtrowaniu, wyświetl komunikat
                if filteredGames.isEmpty {
                    Spacer()
                    Text("Brak ulubionych gier.")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    Spacer()
                } else {
                    // W przeciwnym wypadku wyświetl siatkę gier z przefiltrowanej listy
                    GamesGridView(games: filteredGames, gestureMode: .favorites)
                }
            }
            .navigationBarHidden(true) // Ukrycie domyślnego paska nawigacji
        }
    }
}
