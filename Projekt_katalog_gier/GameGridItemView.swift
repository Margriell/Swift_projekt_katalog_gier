import SwiftUI

// Pojedynczy kafelek gry w siatce – z obsługą gestów
struct GameGridItemView: View {
    @Environment(\.managedObjectContext) private var viewContext

    let game: Game
    var gestureMode: GestureMode = .catalog
    var onDeleteRequested: (() -> Void)? = nil   // Callback do usunięcia gry

    // Stany do wyświetlania overlaya i animacji
    @State private var showOverlay = false
    @State private var overlayColor = Color.clear
    @State private var overlayIcon = ""
    @State private var showTrashIcon = false
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        ZStack {
            // Obraz gry lub placeholder
            if let imageData = game.coverImage, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 115, height: 165)
                    .clipped()
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .offset(x: dragOffset.width)
                    .animation(.spring(), value: dragOffset)

            } else if let imageName = game.coverImageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 115, height: 165)
                    .clipped()
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .offset(x: dragOffset.width)
                    .animation(.spring(), value: dragOffset)

            } else {
                // Placeholder gdy brak obrazka
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 115, height: 165)
                    .overlay(
                        Text(game.title ?? "Brak tytułu")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(8)
                    )
                    .offset(x: dragOffset.width)
                    .animation(.spring(), value: dragOffset)
            }

            // Overlay z ikoną ulubionych
            if showOverlay {
                Color(overlayColor)
                    .opacity(0.5)
                    .frame(width: 115, height: 165)
                    .cornerRadius(8)

                Image(systemName: overlayIcon)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
            }

            // Ikona śmietnika – pojawia się przy swipe w trybie favorites
            if showTrashIcon {
                Image(systemName: "trash.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.red)
                    .offset(x: 60)
                    .transition(.scale)
            }
        }
        // Nakładamy gesty w zależności od trybu
        .modifier(GestureModifier(
            gestureMode: gestureMode,
            onLongPress: {
                withAnimation {
                    toggleFavorite()
                }
            },
            onSwipeRight: {
                withAnimation(.easeIn) {
                    showTrashIcon = true
                    dragOffset = CGSize(width: 100, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation {
                        removeFromFavorites()
                        dragOffset = .zero
                        showTrashIcon = false
                    }
                }
            },
            onDragDropTrash: {
                // Wywołanie callbacku usuwania po dropie
                onDeleteRequested?()
            }
        ))
    }

    // MARK: - Akcje pomocnicze

    // Przełączenie statusu ulubionych i pokazanie overlaya
    private func toggleFavorite() {
        game.isFavorite.toggle()

        showOverlay = true
        overlayColor = game.isFavorite ? .green : .red
        overlayIcon = game.isFavorite ? "heart.fill" : "heart.slash"

        saveContext()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            withAnimation {
                showOverlay = false
            }
        }
    }

    // Usunięcie z ulubionych
    private func removeFromFavorites() {
        game.isFavorite = false
        saveContext()
    }

    // Zapis do Core Data
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
