import SwiftUI
import CoreData

struct CustomGamesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // FetchRequest pobierający własne gry (isCustom == true), posortowane po tytule
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Game.title, ascending: true)],
        predicate: NSPredicate(format: "isCustom == true"),
        animation: .default
    ) private var customGames: FetchedResults<Game>

    // FetchRequest pobierający wszystkie gatunki, posortowane alfabetycznie
    @FetchRequest(
        entity: Genre.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Genre.name, ascending: true)]
    ) var genres: FetchedResults<Genre>

    // Model zarządzający filtrowaniem
    @StateObject private var filterModel = FilterModel()

    // Stan do przechowywania gry wybranej do usunięcia
    @State private var gameToDelete: Game? = nil
    // Flaga wyświetlająca alert potwierdzenia usunięcia
    @State private var showDeleteConfirmation = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 0) {
                    // Nagłówek widoku z tytułem "Własne gry" i żółtym kolorem
                    HeaderView(title: "Własne gry", color: .yellow)

                    // Widok pola wyszukiwania oraz filtrowania po gatunkach
                    SearchAndFilterView(
                        genres: Array(genres),
                        searchText: $filterModel.searchText,
                        selectedGenres: $filterModel.selectedGenres,
                        showGenreFilter: $filterModel.showGenreFilter
                    )

                    // Przefiltrowane gry na podstawie tekstu i wybranych gatunków
                    let filteredGames = filterModel.filterGames(Array(customGames))

                    // Jeśli brak wyników po filtrowaniu, wyświetl komunikat
                    if filteredGames.isEmpty {
                        Spacer()
                        Text("Brak własnych gier.")
                            .foregroundColor(.secondary)
                            .font(.headline)
                        Spacer()
                    } else {
                        // W przeciwnym wypadku wyświetl siatkę gier z możliwością usuwania
                        GamesGridView(
                            games: filteredGames,
                            gestureMode: .customGames,
                            onDelete: { game in
                                // Ustaw grę do usunięcia i pokaż alert
                                gameToDelete = game
                                showDeleteConfirmation = true
                            }
                        )
                        // Przekazanie kontekstu Core Data do widoku siatki
                        .environment(\.managedObjectContext, viewContext)
                    }
                }

                // Przycisk kosza (drag target) i dodawania nowej gry
                VStack(spacing: 16) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .onDrag {
                            NSItemProvider(object: NSString(string: "trash"))
                        }

                    NavigationLink(destination: AddGameView()) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                }
                // Pozycjonowanie przycisków w prawym dolnym rogu ekranu
                .padding(.trailing)
                .padding(.bottom)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
            // Ukrycie domyślnego paska nawigacji
            .navigationBarHidden(true)
            // Alert potwierdzenia usunięcia gry
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Usuń grę?"),
                    message: Text("Czy na pewno chcesz usunąć grę \"\(gameToDelete?.title ?? "")\"?"),
                    primaryButton: .destructive(Text("Usuń")) {
                        if let game = gameToDelete {
                            // Usuwanie gry z Core Data i zapis zmian
                            viewContext.delete(game)
                            do {
                                try viewContext.save()
                            } catch {
                                print("Błąd przy usuwaniu gry: \(error)")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}
