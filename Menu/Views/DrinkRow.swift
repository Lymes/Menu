import SwiftUI

struct DrinkRow: View {
    let title: String
    let image: Image
    let quantity: Int
    let onMinus: () -> Void
    let onPlus: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .cornerRadius(6)

            Text(title)
                .font(.body)

            Spacer()

            HStack(spacing: 12) {
                Button(action: onMinus) {
                    Image(systemName: "minus.circle")
                        .font(.title3)
                }
                Text("\(quantity)")
                    .font(.headline.monospacedDigit())
                    .frame(minWidth: 26)
                Button(action: onPlus) {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                }
            }
            .tint(AppTheme.orange)
        }
        .padding(.vertical, 6)
    }
}
