import SwiftUI

// MARK: - RevealOverlay (neutral)

struct RevealOverlay: View {
    let playerName: String
    let word: String
    let onHide: () -> Void

    @State private var appear = false

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.55))
                .ignoresSafeArea()
                .onTapGesture { onHide() }

            VStack(spacing: 14) {
                Text(playerName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.70))

                Text(word)
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.55)
                    .padding(.horizontal, 10)

                Text("Tap to hide and pass the phone.")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))

                PremiumActionButton(title: "Hide", systemImage: "hand.raised.fill") {
                    onHide()
                }
            }
            .padding(22)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 26, x: 0, y: 16)
            .padding(.horizontal, 18)
            .scaleEffect(appear ? 1 : 0.96)
            .opacity(appear ? 1 : 0)
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    appear = true
                }
            }
        }
    }
}
