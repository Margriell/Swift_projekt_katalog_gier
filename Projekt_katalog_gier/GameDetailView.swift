import SwiftUI

struct GameDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showMessage: Bool = false                 // Flaga do pokazania toastu z komunikatem
    @State private var messageText: String = ""                  // Tekst wyświetlany w toast

    @ObservedObject var game: Game

    // Stany lokalne dla edycji playTime i isCompleted (dostępne tylko gdy gra jest ulubiona)
    @State private var playTimeString: String = ""
    @State private var isCompleted: Bool = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Wyświetlenie okładki gry - najpierw pobieramy obraz z nazwy,
                    // jeśli brak, to ładujemy z danych binarnych, jeśli brak obu, nic nie pokazujemy
                    if let name = game.coverImageName {
                        Image(name)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 8)
                            .frame(maxWidth: .infinity)
                    } else if let imageData = game.coverImage, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 8)
                            .frame(maxWidth: .infinity)
                    }

                    // Pasek z informacjami: wydawca, data wydania i ocena
                    HStack(spacing: 20) {
                        // Wydawca
                        if let publisher = game.publisher {
                            Label(publisher, systemImage: "building.2.crop.circle")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        // Data wydania (sformatowana)
                        if let releaseDate = game.releaseDate {
                            Label {
                                Text(dateFormatter.string(from: releaseDate))
                            } icon: {
                                Image(systemName: "calendar")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Ocena z gwiazdką
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", game.rating))
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Wyświetlenie gatunków gry, jeśli istnieją
                    if let genresSet = game.toGenre as? Set<Genre>, !genresSet.isEmpty {
                        // Sortowanie alfabetyczne gatunków
                        let sortedGenres = genresSet.sorted { ($0.name ?? "") < ($1.name ?? "") }

                        Text("Gatunki:")
                            .font(.headline)
                            .padding(.top, 8)

                        // Pasek z gatunkami przewijany poziomo
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(sortedGenres, id: \.self) { genre in
                                    Text(genre.name ?? "Gatunek")
                                        .font(.caption)
                                        .padding(8)
                                        .background(Color.blue.opacity(0.2))
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }

                    // Sekcja z opisem gry
                    Text("Opis:")
                        .font(.headline)
                        .padding(.top, 8)

                    Text(game.descriptionText ?? "Brak opisu gry.")
                        .font(.body)

                    Spacer()

                    // Sekcja z możliwością edycji dodatkowych pól (dla ulubionych)
                    Group {
                        if game.isFavorite {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Dodatkowe informacje")
                                    .font(.headline)
                                    .padding(.bottom, 4)

                                // Etykieta wyjaśniająca pole czasu gry
                                Text("Ilość godzin spędzonych w grze:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                // Pole do wpisania playTime
                                TextField("Wprowadź czas gry", text: $playTimeString)
                                    .keyboardType(.numberPad)
                                    .padding(10)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)

                                // Etykieta wyjaśniająca przełącznik ukończenia
                                Text("Status ukończenia gry:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                // Przełącznik ukończenia gry
                                Toggle("Ukończona", isOn: $isCompleted)

                                // Klikalny tekst do zapisu
                                Text("Zapisz")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .underline()
                                    .padding(.top)
                                    .onTapGesture {
                                        // Aktualizujemy model Core Data z wartości UI
                                        if let hours = Int16(playTimeString) {
                                            game.playTime = hours
                                        } else {
                                            game.playTime = 0
                                        }
                                        game.isCompleted = isCompleted

                                        // Zapisujemy zmiany
                                        saveContext()
                                        // Pokazujemy komunikat
                                        showToast(message: "Zapisano zmiany")
                                    }
                            }
                            .padding()
                            .background(Color(UIColor.systemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            .onAppear {
                                // Przy wejściu do widoku ustawiamy wartości w UI
                                playTimeString = "\(game.playTime)"
                                isCompleted = game.isCompleted
                            }
                        } else {
                            Text("Dodaj do ulubionych, aby móc dodać czas gry i status ukończenia.")
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .padding(.top, 12)
                        }
                    }
                }
                .padding()
            }

            // Toast z komunikatem wyświetlany na dole ekranu
            if showMessage {
                VStack {
                    Spacer()
                    Text(messageText)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: showMessage)
                }
            }
        }
        // Ustawienia nawigacji - tytuł i przycisk na pasku
        .navigationTitle(game.title ?? "Szczegóły gry")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: toggleFavorite) {
                    // Ikona plus/minus zmienia się w zależności od statusu ulubionych
                    Image(systemName: game.isFavorite ? "minus" : "plus")
                }
            }
        }
    }

    // Funkcja przełączająca status ulubionych i zapisująca zmiany w Core Data
    private func toggleFavorite() {
        game.isFavorite.toggle()
        if !game.isFavorite {
            // Resetujemy playTime i isCompleted, gdy usuwamy z ulubionych
            game.playTime = 0
            game.isCompleted = false
        } else {
            // Przy ustawieniu na ulubioną inicjujemy lokalne stany (dla UI)
            playTimeString = "\(game.playTime)"
            isCompleted = game.isCompleted
        }
        saveContext()
        // Pokazujemy komunikat toast
        showToast(message: game.isFavorite ? "Dodano grę do ulubionych" : "Usunięto grę z ulubionych")
    }

    // Funkcja zapisująca zmiany w Core Data
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Błąd zapisu: \(error.localizedDescription)")
        }
    }

    // Funkcja wyświetlająca toast z podanym tekstem przez 2 sekundy
    private func showToast(message: String) {
        messageText = message
        withAnimation {
            showMessage = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                showMessage = false
            }
        }
    }

    // Formatter do daty
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
