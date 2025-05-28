import SwiftUI

struct GamesGridView: View {
    let games: [Game]                        // Tablica gier do wyświetlenia
    var gestureMode: GestureMode = .catalog // Tryb gestów przekazywany do każdej komórki
    var onDelete: ((Game) -> Void)? = nil   // Callback wywoływany przy usunięciu gry

    // Układ kolumn siatki: 3 elastyczne kolumny
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        ScrollView {
            // Siatka leniwa – elementy ładują się dopiero, gdy trzeba je wyświetlić
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(games) { game in
                    // Każda komórka to przekierowanie do widoku szczegółów gry
                    NavigationLink(destination: GameDetailView(game: game)) {
                        GameGridItemView(
                            game: game,
                            gestureMode: gestureMode,
                            onDeleteRequested: {
                                onDelete?(game)  // Przekazujemy grę do wywołania usunięcia
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
}
