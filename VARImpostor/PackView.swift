import SwiftUI

struct PackView: View {

    @EnvironmentObject var game: GameState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private enum ModeID: String { case players, clubs }
    @State private var selectedID: ModeID = .players
    @State private var pulse = false
    @State private var appear = false

    var body: some View {
        ZStack {
            VStack(spacing: 18) {
                header
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : -20)

                modeCard
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 30)

                Spacer(minLength: 0)
            }
            .onAppear {
                selectedID = (game.roundMode == .clubs) ? .clubs : .players
                pulse = false
                
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appear = true
                }
                
                if !reduceMotion {
                    withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                        pulse = true
                    }
                }
            }

            bottomBar
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 40)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 16) {
            // Back button (compact, top-left)
            HStack {
                Button {
                    Haptics.impact(.light)
                    withAnimation(.easeOut(duration: 0.20)) {
                        game.phase = .home
                    }
                } label: {
                    BrandedIcon(
                        preferred: .asset("icon_back"),
                        fallback: .system("chevron.left"),
                        size: 18,
                        weight: .bold,
                        color: .white
                    )
                    .frame(width: 44, height: 44)
                    .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: BrandMetrics.iconCornerRadius, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: BrandMetrics.iconCornerRadius, style: .continuous).stroke(.white.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Retour")

                Spacer()
            }

            // Hero title (centré, massif comme HomeView)
            VStack(spacing: 10) {
                Image(systemName: "soccerball")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: BrandColors.accentStart.opacity(pulse ? 0.45 : 0.25), radius: pulse ? 20 : 12, y: 0)
                    .scaleEffect(pulse ? 1.02 : 0.98)

                Text("MODES")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.60), radius: 30, y: 16)

                Text("Choisis ton style de jeu")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(.white.opacity(0.20), lineWidth: 1))
                    )
                    .shadow(color: .black.opacity(0.55), radius: 14, y: 9)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 18)
        .padding(.top, 10)
    }

    private var modeCard: some View {
        VStack(spacing: 16) {
            modeRow(
                icon: "person.fill",
                title: "Joueurs",
                subtitle: "Devine qui est l'imposteur",
                id: .players,
                isDisabled: false
            )

            modeRow(
                icon: "shield.lefthalf.filled",
                title: "Clubs",
                subtitle: "Identifie le faux club",
                id: .clubs,
                isDisabled: !game.clubsModeIsHealthy
            )
        }
        .padding(.horizontal, 18)
    }

    private func modeRow(icon: String, title: String, subtitle: String, id: ModeID, isDisabled: Bool) -> some View {
        let isSelected = selectedID == id
        return ModeRowTile(
            icon: icon,
            title: title,
            subtitle: subtitle,
            isDisabled: isDisabled,
            isSelected: isSelected,
            pulse: pulse
        ) {
            if isDisabled {
                Haptics.impact(.light)
                return
            }
            Haptics.impact(.light)
            if reduceMotion {
                selectedID = id
            } else {
                withAnimation(.easeOut(duration: 0.20)) {
                    selectedID = id
                }
            }
        }
    }

    private var bottomBar: some View {
        VStack(spacing: 0) {
            // Bouton CTA (style HomeView)
            Button {
                Haptics.impact(.medium)
                withAnimation(.easeOut(duration: 0.20)) {
                    if selectedID == .clubs && !game.clubsModeIsHealthy {
                        game.roundMode = .players
                    } else {
                        game.roundMode = (selectedID == .clubs) ? .clubs : .players
                    }
                    game.phase = .names
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text("Continuer")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.05, green: 0.78, blue: 0.52),
                                        Color(red: 0.12, green: 0.62, blue: 0.98)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        // Highlight top
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.40), .clear],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1.5
                            )
                            .blendMode(.overlay)
                    }
                )
                .shadow(color: Color(red: 0.12, green: 0.62, blue: 0.98).opacity(0.45), radius: 24, y: 12)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
            .accessibilityLabel("Continuer")
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color.black.opacity(0.0), Color.black.opacity(0.75)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .frame(maxHeight: .infinity, alignment: .bottom)
    }

    private var selectedTitle: String {
        selectedID == .clubs ? "Clubs" : "Joueurs"
    }
}

private struct ModeRowTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let isDisabled: Bool
    let isSelected: Bool
    let pulse: Bool
    let onTap: () -> Void

    private let rowRadius: CGFloat = 28

    // Gradient éclatant pour sélection (comme HomeView)
    private var selectionGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.78, blue: 0.52).opacity(0.85),
                Color(red: 0.12, green: 0.62, blue: 0.98).opacity(0.75)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var cardBackground: some View {
        ZStack {
            // Base sombre
            RoundedRectangle(cornerRadius: rowRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: rowRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.04, green: 0.12, blue: 0.24).opacity(0.88),
                                    Color(red: 0.02, green: 0.10, blue: 0.18).opacity(0.92)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )

            // Glow de sélection
            if isSelected {
                RoundedRectangle(cornerRadius: rowRadius, style: .continuous)
                    .fill(selectionGradient)
                    .opacity(0.15)
                    .blur(radius: 2)
            }

            // Bordure éclatante quand sélectionné
            RoundedRectangle(cornerRadius: rowRadius, style: .continuous)
                .stroke(
                    isSelected ? selectionGradient : 
                    LinearGradient(
                        colors: [.white.opacity(0.12), .white.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: isSelected ? 2 : 1
                )

            // Highlight top
            if isSelected {
                RoundedRectangle(cornerRadius: rowRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.25), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 1
                    )
                    .blendMode(.overlay)
            }
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 18) {
                // Icône large (comme HomeView)
                ZStack {
                    Circle()
                        .fill(
                            isSelected ? selectionGradient :
                            LinearGradient(
                                colors: [Color.white.opacity(0.12), Color.white.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 68, height: 68)
                        .overlay(
                            Circle().stroke(
                                isSelected ? 
                                LinearGradient(
                                    colors: [.white.opacity(0.35), .white.opacity(0.20)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [.white.opacity(0.15), .white.opacity(0.08)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 1.5 : 1
                            )
                        )
                        .shadow(
                            color: isSelected ? Color(red: 0.12, green: 0.62, blue: 0.98).opacity(pulse ? 0.45 : 0.25) : .clear,
                            radius: isSelected ? (pulse ? 20 : 14) : 0,
                            y: 0
                        )

                    Group {
                        if isDisabled {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white.opacity(0.88))
                        } else if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                                .shadow(color: .white.opacity(0.35), radius: 8)
                        } else {
                            Image(systemName: icon)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white.opacity(0.88))
                        }
                    }
                    .scaleEffect(isSelected ? (pulse ? 1.05 : 0.95) : 1.0)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Text(title)
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        if isDisabled {
                            Text("Bientôt")
                                .font(.system(size: 11, weight: .heavy, design: .rounded))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color.yellow.opacity(0.28),
                                            Color.orange.opacity(0.22)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    in: Capsule()
                                )
                                .overlay(Capsule().stroke(Color.yellow.opacity(0.40), lineWidth: 1))
                                .foregroundStyle(.yellow.opacity(0.95))
                        }
                    }

                    Text(subtitle)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer()

                // Chevron discret
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(isSelected ? 0.55 : 0.30))
            }
            .padding(.horizontal, 22)
            .padding(.vertical, 20)
            .contentShape(Rectangle())
            .background(cardBackground)
            .shadow(
                color: isSelected ? Color(red: 0.12, green: 0.62, blue: 0.98).opacity(0.25) : .black.opacity(0.55),
                radius: isSelected ? 28 : 18,
                y: isSelected ? 16 : 12
            )
        }
        .buttonStyle(ModeRowButtonStyle())
        .opacity(isDisabled ? 0.60 : 1.0)
        .saturation(isDisabled ? 0.4 : 1.0)
        .accessibilityLabel("\(title)\(isDisabled ? ", verrouillé" : (isSelected ? ", sélectionné" : ""))")
        .accessibilityHint(isDisabled ? "Pas assez de contenu pour le moment" : "")
        .accessibilityValue(isSelected ? "Sélectionné" : "Non sélectionné")
    }
}

private struct ModeRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: configuration.isPressed)
    }
}

