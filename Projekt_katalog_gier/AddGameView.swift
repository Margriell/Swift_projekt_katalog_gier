import SwiftUI
import CoreData
import PhotosUI

struct AddGameView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode    // Do zamykania widoku po zapisaniu lub anulowaniu

    // Pola formularza
    @State private var title: String = ""
    @State private var publisher: String = ""
    @State private var descriptionText: String = ""
    @State private var rating: Double = 0
    @State private var selectedGenres: Set<Genre> = []
    @State private var isFavorite: Bool = false

    // Flagi do walidacji formularza i śledzenia, czy użytkownik próbował zapisać
    @State private var didAttemptSubmit = false
    @State private var titleTouched = false
    @State private var publisherTouched = false
    @State private var descriptionTouched = false

    // Zarządzanie wyborem zdjęcia dla okładki gry
    @State private var selectedImageItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showImageTooLargeError: Bool = false
    @State private var imageLoadedSuccessfully: Bool = false

    // Pobranie wszystkich dostępnych gatunków z Core Data, posortowanych alfabetycznie
    @FetchRequest(
        entity: Genre.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Genre.name, ascending: true)]
    ) var genres: FetchedResults<Genre>

    var body: some View {
        VStack(spacing: 0) {
            // Nagłówek widoku z tytułem "Dodaj grę" i żółtym kolorem
            ZStack {
                HeaderView(title: "Dodaj grę", color: .yellow)

                // Przycisk wstecz, który zamyka widok
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .padding(.leading)
                    Spacer()
                }
            }

            Form {
                // Sekcja pola tytułu
                Section(header: Text("Tytuł gry")) {
                    TextField("Wprowadź tytuł", text: $title, onEditingChanged: { editing in
                        if !editing { titleTouched = true } // Flaga edycji (jeśli edytowaliśmy pole i je opuściliśmy)
                    })
                        .autocapitalization(.words)

                    // Walidacja pola tytułu: pokazuj komunikat jeśli było edytowane i jest puste
                    if (titleTouched || didAttemptSubmit) && title.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Pole nie może być puste.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // Sekcja pola wydawcy
                Section(header: Text("Wydawca")) {
                    TextField("Wprowadź wydawcę", text: $publisher, onEditingChanged: { editing in
                        if !editing { publisherTouched = true } // Flaga edycji
                    })
                        .autocapitalization(.words)

                    // Walidacja pola wydawcy
                    if (publisherTouched || didAttemptSubmit) && publisher.trimmingCharacters(in: .whitespaces).isEmpty {
                        Text("Pole nie może być puste.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }

                // Sekcja opisu
                Section(header: Text("Opis")) {
                    TextEditor(text: $descriptionText)
                        .frame(minHeight: 100)
                        .onChange(of: descriptionText) { _ in
                            descriptionTouched = true // Flaga edycji
                        }

                    // Jeśli pole opisu było edytowane lub była próba zapisu
                    if descriptionTouched || didAttemptSubmit {
                        if descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            // Pole jest puste — komunikat, że pole nie może być puste
                            Text("Pole nie może być puste.")
                                .foregroundColor(.red)
                                .font(.caption)
                        } else if !isDescriptionValid {
                            // Pole ma tekst, ale mniej niż 10 znaków — komunikat o minimalnej długości
                            Text("Opis musi mieć co najmniej 10 znaków.")
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }

                // Sekcja wyboru obrazu dla okładki
                Section(header: Text("Dodaj obraz")) {
                    PhotosPicker(
                        selection: $selectedImageItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("Wybierz obraz")
                    }
                    .onChange(of: selectedImageItem) { newItem in
                        guard let item = newItem else { return }

                        Task {
                            do {
                                if let data = try await item.loadTransferable(type: Data.self) {
                                    if data.count > 4_194_304 { // 4MB limit na rozmiar obrazu
                                        showImageTooLargeError = true
                                        imageLoadedSuccessfully = false
                                        selectedImageData = nil
                                    } else {
                                        selectedImageData = data
                                        imageLoadedSuccessfully = true
                                        showImageTooLargeError = false
                                    }
                                }
                            } catch {
                                print("Błąd wczytywania obrazu: \(error.localizedDescription)")
                            }
                        }
                    }

                    // Komunikaty o stanie załadowania obrazu
                    if showImageTooLargeError {
                        Text("Obrazek jest za duży. Maksymalny rozmiar to 4 MB.")
                            .foregroundColor(.red)
                            .font(.caption)
                    } else if imageLoadedSuccessfully {
                        Text("Obraz został dodany poprawnie.")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }

                // Sekcja oceny gry – suwak i wyświetlana wartość
                Section(header: Text("Ocena")) {
                    Slider(value: $rating, in: 0...10, step: 0.1)
                    Text("Ocena: \(rating, specifier: "%.1f")/10")
                }

                // Sekcja ulubionych – przełącznik
                Section(header: Text("Ulubiona")) {
                    Toggle("Dodaj do ulubionych", isOn: $isFavorite)
                }

                // Sekcja wyboru gatunków
                Section(header: Text("Gatunki")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(genres, id: \.self) { genre in
                                Button(action: {
                                    if selectedGenres.contains(genre) {
                                        selectedGenres.remove(genre) // Usuwamy z wybranych
                                    } else {
                                        selectedGenres.insert(genre) // Dodajemy do wybranych
                                    }
                                }) {
                                    Text(genre.name ?? "Nieznany")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(selectedGenres.contains(genre) ? Color.blue : Color.gray.opacity(0.3))
                                        .foregroundColor(selectedGenres.contains(genre) ? .white : .primary)
                                        .cornerRadius(15)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(selectedGenres.contains(genre) ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical, 5)
                    }

                    // Przycisk czyszczący wybrane gatunki, jeśli jakieś są
                    if !selectedGenres.isEmpty {
                        Button("Wyczyść gatunki") {
                            selectedGenres.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                }

                // Przycisk zapisu gry
                Button("Zapisz") {
                    didAttemptSubmit = true // Ustawiamy flagę próby zapisu (uruchamia walidację)
                    if isFormValid() {
                        addGame() // Dodajemy nową grę do Core Data
                        presentationMode.wrappedValue.dismiss() // Zamykamy widok
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(!isFormValid()) // Blokujemy przycisk, jeśli formularz jest niepoprawny
            }
        }
        .navigationBarBackButtonHidden(true) // Ukrywamy systemowy przycisk wstecz
    }

    // Sprawdzenie, czy opis ma co najmniej 10 znaków (po usunięciu białych znaków)
    private var isDescriptionValid: Bool {
        descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).count >= 10
    }

    // Walidacja wypełnienia formularza - tytuł, wydawca i opis
    private func isFormValid() -> Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !publisher.trimmingCharacters(in: .whitespaces).isEmpty &&
        isDescriptionValid
    }

    // Funkcja dodająca nową grę do Core Data
    private func addGame() {
        let newGame = Game(context: viewContext)
        newGame.id = UUID()
        newGame.title = title.trimmingCharacters(in: .whitespaces)
        newGame.publisher = publisher.trimmingCharacters(in: .whitespaces)
        newGame.descriptionText = descriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        newGame.rating = rating
        newGame.isFavorite = isFavorite
        newGame.isCustom = true
        newGame.coverImageName = nil
        newGame.coverImage = selectedImageData
        newGame.toGenre = NSSet(set: selectedGenres)

        do {
            try viewContext.save()
        } catch {
            print("Błąd podczas zapisywania gry: \(error.localizedDescription)")
        }
    }
}
