import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // FetchRequest pobierający gry, które nie są własne (isCustom == false), posortowane po tytule
    @FetchRequest(
        entity: Game.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.title, ascending: true)],
        predicate: NSPredicate(format: "isCustom == false")
    ) var games: FetchedResults<Game>

    // FetchRequest pobierający wszystkie gatunki, posortowane alfabetycznie
    @FetchRequest(
        entity: Genre.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Genre.name, ascending: true)]
    ) var genres: FetchedResults<Genre>

    // Model zarządzający filtrowaniem
    @StateObject private var filterModel = FilterModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Nagłówek widoku z tytułem "Katalog gier" i kolorem indygo
                HeaderView(title: "Katalog gier", color: .indigo)

                // Widok pola wyszukiwania oraz filtrowania po gatunkach
                SearchAndFilterView(
                    genres: Array(genres),
                    searchText: $filterModel.searchText,
                    selectedGenres: $filterModel.selectedGenres,
                    showGenreFilter: $filterModel.showGenreFilter
                )

                // Przefiltrowane gry na podstawie wpisanego tekstu i wybranych gatunków
                let filteredGames = filterModel.filterGames(Array(games))

                // Jeśli brak wyników po filtrowaniu, wyświetl komunikat
                if filteredGames.isEmpty {
                    Spacer()
                    Text("Brak gier w katalogu.")
                        .foregroundColor(.secondary)
                        .font(.headline)
                    Spacer()
                } else {
                    // W przeciwnym wypadku wyświetl siatkę gier z przefiltrowanej listy
                    GamesGridView(games: filteredGames, gestureMode: .catalog)
                }
            }
            // Ukrycie domyślnego paska nawigacji
            .navigationBarHidden(true)
        }
    }
}
