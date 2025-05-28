import SwiftUI

// Widok z polem wyszukiwania i możliwością filtrowania listy po gatunkach
struct SearchAndFilterView: View {
    let genres: [Genre]
    @Binding var searchText: String
    @Binding var selectedGenres: Set<Genre>       
    @Binding var showGenreFilter: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Pole tekstowe do wyszukiwania
            TextField("Wyszukaj...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .padding(.top, 8)

            // Przycisk, który pokazuje lub ukrywa panel filtrów gatunków z animacją
            Button(action: {
                withAnimation {
                    showGenreFilter.toggle()
                }
            }) {
                HStack {
                    Text("Filtruj po gatunkach")
                    Spacer()
                    // Ikona strzałki zmienia się w zależności od stanu pokazywania filtra
                    Image(systemName: showGenreFilter ? "chevron.up" : "chevron.down")
                }
                .padding(.horizontal)
            }

            // Sekcja z filtrami gatunków widoczna tylko gdy showGenreFilter == true
            if showGenreFilter {
                // Siatka adaptacyjna
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 10) {
                    ForEach(genres, id: \.self) { genre in
                        Button(action: {
                            toggleGenre(genre) // Przełącz wybór gatunku po tapnięciu
                        }) {
                            Text(genre.name ?? "Gatunek")
                                .font(.caption)
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                // Kolor tła zmienia się, jeśli gatunek jest wybrany
                                .background(selectedGenres.contains(genre) ? Color.blue : Color.gray.opacity(0.3))
                                .foregroundColor(selectedGenres.contains(genre) ? .white : .primary)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 4)

                // Przycisk do wyczyszczenia filtrów, pojawia się tylko gdy coś jest wybrane
                if !selectedGenres.isEmpty {
                    Button("Wyczyść filtry") {
                        selectedGenres.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.bottom, 16)
                }
            } else {
                // Gdy filtr gatunków jest ukryty, zostaw trochę przestrzeni
                Spacer().frame(height: 10)
            }
        }
    }
    
    // Funkcja do przełączania stanu wyboru gatunku - dodaj lub usuń z wybranych
    private func toggleGenre(_ genre: Genre) {
        if selectedGenres.contains(genre) {
            selectedGenres.remove(genre)
        } else {
            selectedGenres.insert(genre)
        }
    }
}
