import SwiftUI

// Nagłówek z wyśrodkowanym tytułem i kolorowym tłem
struct HeaderView: View {
    let title: String
    let color: Color

    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.largeTitle.bold())
                .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(color)
    }
}

