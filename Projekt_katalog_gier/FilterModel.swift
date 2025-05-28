import Foundation
import SwiftUI

class FilterModel: ObservableObject {
    @Published var searchText: String = ""          // Tekst wpisany w pole wyszukiwania
    @Published var selectedGenres: Set<Genre> = []  // Wybrane gatunki do filtrowania
    @Published var showGenreFilter: Bool = false    // Flaga pokazująca/ukrywająca filtr gatunków
    
    // Tablica gier przefiltrowanych na podstawie wyszukiwania i wybranych gatunków
    func filterGames(_ games: [Game]) -> [Game] {
        games.filter { game in
            // Sprawdzenie, czy tytuł gry zawiera tekst wyszukiwania (ignorując wielkość liter)
            let matchesSearch = searchText.isEmpty || (game.title?.localizedCaseInsensitiveContains(searchText) ?? false)
            // Sprawdzenie, czy gatunki gry zawierają wszystkie wybrane gatunki (lub gdy brak filtrów)
            let matchesGenres = selectedGenres.isEmpty || (game.toGenre as? Set<Genre>)?.isSuperset(of: selectedGenres) ?? false
            return matchesSearch && matchesGenres
        }
    }
}
