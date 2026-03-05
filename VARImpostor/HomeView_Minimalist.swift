import SwiftUI
import UIKit

// ✨ VERSION MINIMALISTE - FALSE NINE
// Suppressions : Badge mode, Trust alert, Icônes circulaires

struct HomeView_Minimalist: View {
    @EnvironmentObject var game: GameState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appear = false
    @State private var pulse = false
    @State private var showImpostorPicker = false

    // Brand
    private let appName = "FALSE NINE"
    private let subtitle = "L'un de vous est le Faux Neuf."
    private let radius: CGFloat = 28

    private var canStart: Bool { 
        game.playersCount >= 3 && game.impostorCount < game.playersCount
    }

    var body: some View {
        ZStack {
            Color(red: 0.02, green: 0.04, blue: 0.10)
                .ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color(red: 0.05, green: 0.35, blue: 0.28).opacity(0.55),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 0.0),
                startRadius: 10,
                endRadius: 420
            )
            .ignoresSafeArea()
            
            RadialGradient(
                colors: [
                    Color(red: 0.08, green: 0.20, blue: 0.45).opacity(0.35),
                    Color.clear
                ],
                center: UnitPoint(x: 0.5, y: 1.0),
                startRadius: 10,
                endRadius: 380
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Spacer(minLength: 10)

                header
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 10)

                settingsCard
                    .padding(.horizontal, 18)
                    .padding(.top, 6)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 14)

                Spacer(minLength: 14)

                startSection
                    .padding(.horizontal, 18)
                    .padding(.bottom, 20)
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 14)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.55)) { appear = true }

            pulse = false
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.35).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
        .confirmationDialog("Imposteurs", isPresented: $showImpostorPicker, titleVisibility: .visible) {
            Button("1 imposteur (recommandé)") { game.impostorCount = 1 }
            Button("2 imposteurs") {
                if game.playersCount >= 4 {
                    game.impostorCount = 2
                } else {
                    Haptics.impact(.light)
                }
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Choisis le nombre d'imposteurs pour la partie.")
        }
    }

    // MARK: - Header (✨ SIMPLIFIÉ)

    private var header: some View {
        VStack(spacing: 0) {
            // ✅ SUPPRIMÉ : Badge "Mode: Joueurs" (doublon inutile)
            
            // Titre
            ZStack {
                // Ombre de profondeur
                Text(appName)
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.black.opacity(0.50))
                    .offset(y: 3)
                    .blur(radius: 2)
                
                // Texte principal
                Text(appName)
                    .font(.system(size: 54, weight: .heavy, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.85)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.70), radius: 30, y: 16)
                    .shadow(
                        color: Color(red: 0.05, green: 0.78, blue: 0.52).opacity(pulse ? 0.45 : 0.22),
                        radius: pulse ? 50 : 28,
                        y: 0
                    )
                    .shadow(
                        color: Color(red: 0.12, green: 0.62, blue: 0.98).opacity(pulse ? 0.25 : 0.12),
                        radius: pulse ? 40 : 22,
                        y: 0
                    )
            }
            .scaleEffect(appear ? 1.0 : 0.92)
            .opacity(appear ? 1.0 : 0.0)
            .background(
                RadialGradient(
                    colors: [
                        BrandColors.accentStart.opacity(pulse ? 0.12 : 0.06),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 10,
                    endRadius: 240
                )
                .blur(radius: 16)
                .frame(width: 520, height: 240)
                .offset(y: 18)
                .blendMode(.screen)
            )
            .accessibilityLabel("FALSE NINE")
            .padding(.top, 30) // ✅ Plus d'espace en haut

            // Espacement
            Spacer()
                .frame(height: 24)

            // Sous-titre (dans sa capsule)
            Text(subtitle)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay(
                            Capsule().stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.28),
                                        .white.opacity(0.14)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                        )
                )
                .shadow(color: .black.opacity(0.60), radius: 16, y: 10)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .accessibilityLabel(subtitle)

            // ✅ SUPPRIMÉ : "NE FAIS CONFIANCE À PERSONNE" (redondant)
            
            // Espacement avant la carte
            Spacer()
                .frame(height: 20)
        }
        .padding(.top, 10)
    }

    // MARK: - Settings card (✨ SIMPLIFIÉ)

    private var settingsCard: some View {
        VStack(spacing: 0) {
            // ✅ HomeRow SANS icônes circulaires
            HomeRow(
                title: "Joueurs",
                trailing: "\(max(game.playersCount, 0))",
                footnote: canStart ? nil : "Besoin de 3+ joueurs pour démarrer.",
                isEmphasized: !canStart
            ) {
                Haptics.impact(.light)
                game.phase = .names
            }
            .accessibilityLabel("Joueurs: \(game.playersCount)")

            Spacer().frame(height: 12) // ✅ Espacement augmenté
            softDivider
            Spacer().frame(height: 12)

            HomeRow(
                title: "Imposteurs",
                trailing: "\(game.impostorCount)",
                footnote: nil,
                isEmphasized: false
            ) {
                Haptics.impact(.light)
                showImpostorPicker = true
            }
            .accessibilityLabel("Imposteurs: \(game.impostorCount)")

            Spacer().frame(height: 12)
            softDivider
            Spacer().frame(height: 12)

            HomeRow(
                title: "Mode",
                trailing: game.roundMode.label,
                footnote: nil,
                isEmphasized: false
            ) {
                Haptics.impact(.light)
                game.phase = .pack
            }
            .accessibilityLabel("Mode: \(game.roundMode.label)")
        }
        .padding(.vertical, 16) // ✅ Padding augmenté
        .padding(.horizontal, 4)
        .background(cardBackground)
        .overlay(cardHighlight)
        .overlay(cardVignette)
        .overlay(dangerBorder)
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
        RoundedRectangle(cornerRadius: radius, style: .continuous)
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
        RoundedRectangle(cornerRadius: radius, style: .continuous)
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

    private var dangerBorder: some View {
        Group {
            if !canStart {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
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
                        Color.white.opacity(0.14),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
            .padding(.leading, 60) // ✅ Ajusté (plus d'icône à gauche)
            .padding(.trailing, 20)
    }

    // MARK: - Start section

    private var startSection: some View {
        VStack(spacing: 12) {
            PremiumActionButton(
                title: canStart ? "Démarrer" : validationMessage,
                systemImage: canStart ? "play.fill" : "exclamationmark.triangle.fill",
                gradient: LinearGradient(
                    colors: canStart ? [
                        Color(red: 0.05, green: 0.78, blue: 0.52),
                        Color(red: 0.12, green: 0.62, blue: 0.98)
                    ] : [
                        Color.white.opacity(0.14),
                        Color.white.opacity(0.10)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                isEnabled: canStart,
                isPulsing: canStart
            ) {
                guard canStart else {
                    Haptics.impact(.light)
                    return
                }
                Haptics.impact(.medium)
                game.prepareNewSessionKeepingPlayers()
                game.beginDistribution()
            }
        }
    }
    
    private var validationMessage: String {
        if game.playersCount < 3 {
            return "Besoin de 3+ joueurs"
        } else if game.impostorCount >= game.playersCount {
            return "Trop d'imposteurs"
        } else {
            return "Configurer"
        }
    }
}

// MARK: - HomeRow (✨ MINIMALISTE - SANS ICÔNES)

private struct HomeRow: View {
    let title: String
    let trailing: String
    let footnote: String?
    let isEmphasized: Bool
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // ✅ SUPPRIMÉ : Cercle avec icône
                // Juste le label texte
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 19, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    if let footnote {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .font(.system(size: 11, weight: .bold))
                            Text(footnote)
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundStyle(.red.opacity(0.90))
                        .lineLimit(1)
                    }
                }

                Spacer()

                // Valeur (pill)
                Text(trailing)
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.05, green: 0.70, blue: 0.50).opacity(0.25),
                                            Color(red: 0.08, green: 0.45, blue: 0.80).opacity(0.20)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )

                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.10, green: 0.85, blue: 0.60).opacity(0.55),
                                            Color(red: 0.15, green: 0.60, blue: 0.95).opacity(0.40)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1.5
                                )
                        }
                        .shadow(
                            color: Color(red: 0.05, green: 0.78, blue: 0.52).opacity(0.20),
                            radius: 10, y: 4
                        )
                    )

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white.opacity(0.60))
                    .padding(.leading, 6)
            }
            .padding(.horizontal, 24) // ✅ Plus d'espace latéral
            .padding(.vertical, 20)
            .contentShape(Rectangle())
            .background(pressedBackground)
            .scaleEffect(pressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.80), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !pressed { pressed = true } }
                .onEnded { _ in pressed = false }
        )
    }

    private var pressedBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color.white.opacity(pressed ? 0.10 : 0.0))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
    }
}
