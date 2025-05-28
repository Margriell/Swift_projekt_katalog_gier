import SwiftUI

// Tryby gestów - decydują, jakie gesty są aktywne w danym widoku
enum GestureMode {
    case catalog        // przetrzymanie - dodaj/usuń z ulubionych
    case favorites      // przesunięcie w prawo - usuń z ulubionych
    case customGames    // przetrzymanie + przeciąganie śmietnika - usuń z bazy danych
}

// MARK: - Gesture Modifier
// Modyfikator widoku, który dodaje odpowiednie gesty zależnie od trybu
struct GestureModifier: ViewModifier {
    let gestureMode: GestureMode
    let onLongPress: () -> Void
    let onSwipeRight: () -> Void
    let onDragDropTrash: (() -> Void)?

    func body(content: Content) -> some View {
        switch gestureMode {
        case .catalog:
            // W trybie katalogu – tylko przetrzymanie
            content.gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in onLongPress() }
            )

        case .favorites:
            // W trybie ulubionych – przeciągnij w prawo, aby usunąć
            content.gesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        if value.translation.width > 50 {
                            onSwipeRight()
                        }
                    }
            )

        case .customGames:
            // W trybie własnych gier – długi tap + obsługa upuszczenia ikony śmietnika
            content
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in onLongPress() }
                )
                .onDrop(of: [.plainText], isTargeted: nil) { _ in
                    onDragDropTrash?()
                    return true
                }
        }
    }
}
