import SwiftUI

struct NamesView: View {

    @EnvironmentObject var game: GameState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var names: [String] = ["", "", ""]
    @FocusState private var focusedIndex: Int?
    @State private var appear = false
    @State private var pulse = false

    // MARK: - Validation

    private var cleanedNames: [String] {
        names
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private var hasDuplicates: Bool {
        let lower = cleanedNames.map { $0.lowercased() }
        return Set(lower).count != lower.count
    }

    private var canStart: Bool {
        cleanedNames.count >= 3 && !hasDuplicates
    }
    
    private var hasError: Bool {
        hasDuplicates || cleanedNames.count < 3
    }

    // MARK: - UI

    var body: some View {
        VStack(spacing: 18) {
            header
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : -20)

            playersCard
                .padding(.horizontal, 18)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 30)

            addPlayerButton
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 20)

            Spacer(minLength: 0)

            startSection
                .padding(.horizontal, 18)
                .padding(.bottom, 22)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 40)
        }
        .onAppear {
            loadSavedPlayersIntoFields()
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                appear = true
            }
            
            pulse = false
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
        .onChange(of: names) { _, _ in
            syncToGame()
        }
    }

    // MARK: - Persist bridge (UI fields <-> GameState.players)

    private func loadSavedPlayersIntoFields() {
        let saved = game.players.map { $0.name }

        // If nothing saved, keep the 3 empty fields.
        guard !saved.isEmpty else {
            if names.count < 3 { names = ["", "", ""] }
            return
        }

        var filled = saved
        while filled.count < 3 { filled.append("") }
        names = filled
    }

    private func syncToGame() {
        game.players = cleanedNames.map { Player(name: $0) }
    }

    // MARK: - Header (style héroïque)

    private var header: some View {
        VStack(spacing: 16) {
            // Back button aligned left
            HStack {
                Button {
                    Haptics.impact(.light)
                    game.phase = .home
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

            // Hero title centré
            VStack(spacing: 10) {
                Image(systemName: "person.3.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: BrandColors.accentStart.opacity(pulse ? 0.45 : 0.25), radius: pulse ? 20 : 12, y: 0)
                    .scaleEffect(pulse ? 1.02 : 0.98)

                Text("JOUEURS")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.60), radius: 30, y: 16)

                Text("Entre les noms de chaque joueur")
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

    // MARK: - Players card (allégée + dividers doux)

    private var playersCard: some View {
        VStack(spacing: 0) {
            ForEach(names.indices, id: \.self) { i in
                playerRow(i)

                if i != names.indices.last {
                    softDivider
                }
            }

            if hasDuplicates {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 13, weight: .bold))
                    Text("Doublons détectés. Chaque joueur doit avoir un nom unique.")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(.red.opacity(0.90))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .padding(.top, 14)
                .padding(.bottom, 8)
            }
        }
        .padding(.vertical, 12)
        .background(cardBackground)
        .overlay(cardHighlight)
        .overlay(cardVignette)
        .overlay(errorBorder)
        .shadow(color: .black.opacity(0.72), radius: 30, y: 18)
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
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
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.22), .white.opacity(0.06)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: .black.opacity(0.50), radius: 24, y: 14)
    }
    
    private var cardHighlight: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.20),
                        .white.opacity(0.08),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
            .blendMode(.overlay)
    }
    
    private var cardVignette: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(
                RadialGradient(
                    colors: [
                        .clear,
                        .black.opacity(0.35)
                    ],
                    center: .center,
                    startRadius: 90,
                    endRadius: 420
                )
            )
            .blendMode(.multiply)
            .allowsHitTesting(false)
    }
    
    private var errorBorder: some View {
        Group {
            if hasError {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.red.opacity(pulse ? 0.45 : 0.25),
                                Color.orange.opacity(pulse ? 0.35 : 0.20)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .blur(radius: 0.5)
                    .shadow(color: .red.opacity(pulse ? 0.35 : 0.20), radius: pulse ? 16 : 8, y: 0)
            }
        }
    }
    
    private var softDivider: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.06),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.leading, 20)
            .padding(.trailing, 20)
    }

    private func playerRow(_ i: Int) -> some View {
        HStack(spacing: 14) {

            TextField("Joueur \(i + 1)", text: Binding(
                get: { names[i] },
                set: { names[i] = $0 }
            ))
            .focused($focusedIndex, equals: i)
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled(true)
            .submitLabel(i == names.count - 1 ? .done : .next)
            .onSubmit {
                if i < names.count - 1 { focusedIndex = i + 1 }
                else { focusedIndex = nil }
            }
            .font(.system(size: 19, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .tint(BrandColors.accentStart)

            Spacer(minLength: 8)

            // DELETE - Redesigned
            Button {
                Haptics.impact(.light)
                removePlayerSafely(at: i)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white.opacity(0.35))
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                Circle().strokeBorder(
                                    .white.opacity(0.12),
                                    lineWidth: 1
                                )
                            )
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Supprimer le joueur")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
        .onTapGesture { focusedIndex = i }
    }

    // MARK: - Remove player (SAFE + min 3)

    private func removePlayerSafely(at index: Int) {
        guard names.indices.contains(index) else { return }

        // Minimum 3 lignes: on ne supprime pas, on vide juste le texte.
        guard names.count > 3 else {
            names[index] = ""
            if focusedIndex == index { focusedIndex = nil }
            return
        }

        // Ajuste le focus avant suppression (évite bugs)
        if let f = focusedIndex {
            if f == index {
                focusedIndex = nil
            } else if f > index {
                focusedIndex = f - 1
            }
        }

        names.remove(at: index)

        // Sécurité: jamais descendre sous 3 champs
        if names.count < 3 {
            while names.count < 3 { names.append("") }
        }
    }

    // MARK: - Add player (gradient vert)

    private var addPlayerButton: some View {
        Button {
            Haptics.impact(.medium)
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                names.append("")
                focusedIndex = names.count - 1
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.05, green: 0.78, blue: 0.52),
                                Color(red: 0.12, green: 0.62, blue: 0.98)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("Ajouter un joueur")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.80))
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: 240)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule().strokeBorder(
                            .white.opacity(0.12),
                            lineWidth: 1
                        )
                    )
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 18)
    }

    // MARK: - Start section (style HomeView)

    private var startSection: some View {
        VStack(spacing: 12) {
            PremiumActionButton(
                title: "Démarrer",
                systemImage: "play.fill",
                gradient: LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.78, blue: 0.52).opacity(canStart ? 1.0 : 0.35),
                        Color(red: 0.12, green: 0.62, blue: 0.98).opacity(canStart ? 0.95 : 0.25)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                isEnabled: canStart,
                isPulsing: canStart
            ) {
                guard canStart else { return }
                Haptics.impact(.medium)

                let final = cleanedNames
                game.players = final.map { Player(name: $0) }
                game.currentIndex = 0
                game.beginDistribution()
            }

            // Footer avec icônes (style HomeView)
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 11, weight: .bold))
                    Text("3+ joueurs")
                        .font(.system(size: 12, weight: .semibold))
                }
                
                Circle()
                    .fill(Color.white.opacity(0.35))
                    .frame(width: 3, height: 3)
                
                HStack(spacing: 6) {
                    Image(systemName: "text.badge.xmark")
                        .font(.system(size: 11, weight: .bold))
                    Text("Pas de doublons")
                        .font(.system(size: 12, weight: .semibold))
                }
            }
            .foregroundStyle(.white.opacity(0.55))
            .padding(.horizontal, 18)
        }
    }
}
