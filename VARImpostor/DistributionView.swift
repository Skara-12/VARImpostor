import SwiftUI

struct DistributionView: View {
    @EnvironmentObject var game: GameState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pulse = false

    private var totalPlayers: Int { max(1, game.players.count) }

    private var currentPlayerNumber: Int {
        min(max(1, game.currentIndex + 1), totalPlayers)
    }

    private var currentPlayerName: String {
        guard game.players.indices.contains(game.currentIndex) else { return "Player" }
        return game.players[game.currentIndex].name
    }

    private var currentWord: String {
        game.wordForPlayer(at: game.currentIndex)
    }

    var body: some View {
        ZStack {
            // Background général bleu-nuit froid
            Color(red: 0.02, green: 0.04, blue: 0.10)
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                Spacer(minLength: 0)

                header

                Spacer(minLength: 12)

                ZStack {
                    SwipeRevealCard(
                        playerName: currentPlayerName,
                        word: currentWord,
                        pulse: pulse,
                        onReveal: { },
                        onHideAndNext: {
                            Haptics.impact(.light)
                            withAnimation(.spring(response: 0.48, dampingFraction: 0.88)) {
                                game.markRevealedAndAdvance()
                            }
                        }
                    )
                    .id(game.currentIndex) // reset states per player
                    .transition(
                        .asymmetric(
                            insertion: .premiumSlide(direction: .trailing),
                            removal: .premiumSlide(direction: .leading)
                        )
                    )
                }
                .animation(.spring(response: 0.48, dampingFraction: 0.88), value: game.currentIndex)

                Spacer(minLength: 60)
            }
        }
        .onAppear {
            if game.players.isEmpty { game.phase = .names }
            
            pulse = false
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
    }

    // MARK: - Header (améliore avec effet 3D)

    private var header: some View {
        VStack(spacing: 12) {
            Text("Passe le téléphone à")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))

            // Nom avec effet 3D (comme FALSE NINE)
            ZStack {
                // Ombre de profondeur
                Text(currentPlayerName.uppercased())
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(.black.opacity(0.50))
                    .offset(y: 2)
                    .blur(radius: 1.5)
                
                // Texte principal
                Text(currentPlayerName.uppercased())
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.60), radius: 20, y: 12)
                    .shadow(color: BrandColors.accentStart.opacity(pulse ? 0.35 : 0.20), radius: pulse ? 30 : 18, y: 0)
            }
            .lineLimit(1)
            .minimumScaleFactor(0.60)
            .padding(.horizontal, 18)

            HStack(spacing: 8) {
                Image(systemName: "person.fill")
                    .font(.system(size: 11, weight: .bold))
                Text("Joueur \(currentPlayerNumber)/\(totalPlayers)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.65))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.50))
                    .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
            )

            SegmentedProgressBar(total: totalPlayers, current: currentPlayerNumber, pulse: pulse)
                .padding(.horizontal, 22)
                .padding(.top, 4)
        }
    }
}

// MARK: - Segmented progress (premium avec glow)
private struct SegmentedProgressBar: View {
    let total: Int
    let current: Int
    let pulse: Bool

    private var safeTotal: Int { max(1, total) }
    private var safeCurrent: Int { min(max(1, current), safeTotal) }

    var body: some View {
        HStack(spacing: 7) {
            ForEach(1...safeTotal, id: \.self) { idx in
                Capsule()
                    .fill(
                        idx <= safeCurrent
                        ? AnyShapeStyle(fillGradient)
                        : AnyShapeStyle(Color.white.opacity(0.22))
                    )
                    .overlay(
                        Capsule().stroke(
                            idx <= safeCurrent
                            ? LinearGradient(
                                colors: [
                                    BrandColors.strokeStart.opacity(0.50),
                                    BrandColors.strokeEnd.opacity(0.35)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color.white.opacity(0.12)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                    )
                    .shadow(
                        color: idx == safeCurrent ? BrandColors.accentStart.opacity(pulse ? 0.45 : 0.25) : .clear,
                        radius: idx == safeCurrent ? (pulse ? 12 : 8) : 0,
                        y: 0
                    )
                    .frame(height: 13)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: safeCurrent)
            }
        }
        .padding(.vertical, 2)
    }

    private var fillGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.78, blue: 0.52),
                Color(red: 0.12, green: 0.62, blue: 0.98)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

