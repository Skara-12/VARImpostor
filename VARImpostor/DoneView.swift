import SwiftUI
import UIKit

// MARK: - Done View (Round Complete)
struct DoneView: View {
    @EnvironmentObject var game: GameState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appear = false
    @State private var pulse = false

    var body: some View {
        VStack(spacing: 20) {
            // Bouton retour (cohérence avec les autres vues)
            HStack {
                Button {
                    Haptics.impact(.light)
                    game.phase = .revealImpostor
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
                .accessibilityLabel("Retour à la révélation")
                
                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
            .opacity(appear ? 1 : 0)
            
            Spacer(minLength: 20)

            // Header avec icône
            VStack(spacing: 18) {
                // Icon avec glow
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle().stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.30), .white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                        )
                        .shadow(color: .black.opacity(0.30), radius: 20, y: 10)

                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
                }
                .scaleEffect(pulse ? 1.04 : 1.0)
                
                Text("C'EST PARTI !")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.60), radius: 30, y: 16)
                    .shadow(
                        color: Color(red: 0.05, green: 0.78, blue: 0.52).opacity(pulse ? 0.40 : 0.20),
                        radius: pulse ? 45 : 25,
                        y: 0
                    )
                    .shadow(
                        color: Color(red: 0.12, green: 0.62, blue: 0.98).opacity(pulse ? 0.22 : 0.10),
                        radius: pulse ? 35 : 18,
                        y: 0
                    )
                
                Text("À vous de jouer !")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 32)
            }
            .scaleEffect(appear ? 1 : 0.92)
            .opacity(appear ? 1 : 0)
            
            // Info card avec stats
            infoCard
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .scaleEffect(appear ? 1 : 0.90)
                .opacity(appear ? 1 : 0)
            
            Spacer(minLength: 10)

            // Boutons d'action
            VStack(spacing: 14) {
                nextRoundButton
                backToHomeButton
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                appear = true
            }
            
            // Pulse animation
            pulse = false
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
    }
    
    // MARK: - Info Card
    
    private var infoCard: some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        
        return VStack(spacing: 0) {
            // Badge de confirmation amélioré
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 14, weight: .bold))
                
                Text("ROUND VALIDÉ")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
                    .tracking(1.2)
            }
            .foregroundStyle(.white.opacity(0.90))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.05, green: 0.78, blue: 0.52).opacity(0.20),
                                    Color(red: 0.12, green: 0.62, blue: 0.98).opacity(0.15)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
            )
            .overlay(
                Capsule()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color(red: 0.10, green: 0.85, blue: 0.60).opacity(0.45),
                                Color(red: 0.15, green: 0.60, blue: 0.95).opacity(0.30)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: Color(red: 0.05, green: 0.78, blue: 0.52).opacity(0.20),
                radius: 10, y: 5
            )
            .accessibilityLabel("Round validé et prêt")
            .padding(.bottom, 20)
            
            // Stats
            HStack(spacing: 20) {
                statItem(icon: "flag.checkered", label: "Round", value: "\(game.round)")
                
                Divider()
                    .frame(height: 40)
                    .overlay(Color.white.opacity(0.15))
                
                statItem(icon: "person.2.fill", label: "Joueurs", value: "\(game.players.count)")
                
                if !game.categoryTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Divider()
                        .frame(height: 40)
                        .overlay(Color.white.opacity(0.15))
                    
                    statItem(icon: "tag.fill", label: "Type", value: game.categoryTitle)
                }
            }
            .padding(.top, 4)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                shape
                    .fill(.ultraThinMaterial)
                
                shape
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.04, green: 0.12, blue: 0.24).opacity(0.88),
                                Color(red: 0.03, green: 0.10, blue: 0.20).opacity(0.92)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                shape
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.05, green: 0.70, blue: 0.50).opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 50,
                            endRadius: 250
                        )
                    )
                    .blendMode(.screen)
            }
        )
        .clipShape(shape)
        .overlay(
            shape.stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.20),
                        .white.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
        )
        .shadow(color: .black.opacity(0.40), radius: 30, y: 15)
    }
    
    private func statItem(icon: String, label: String, value: String) -> some View {
        VStack(spacing: 10) {
            // Icône avec background circulaire
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.18),
                                Color.white.opacity(0.10)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Circle().stroke(
                            Color.white.opacity(0.25),
                            lineWidth: 1
                        )
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.90))
            }
            
            Text(value)
                .font(.system(size: 22, weight: .black, design: .rounded))
                .minimumScaleFactor(0.60)
                .lineLimit(1)
                .truncationMode(.middle)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .white.opacity(0.20), radius: 8, y: 4)
            
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.60))
                .textCase(.uppercase)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Action Buttons
    
    private var nextRoundButton: some View {
        Button {
            Haptics.impact(.medium)
            game.nextRound()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 19, weight: .bold))
                
                VStack(spacing: 2) {
                    Text("Nouveau Round")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                    
                    Text("Round \(game.round + 1)")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .opacity(0.75)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                ZStack {
                    // Gradient principal (brand CTA)
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.05, green: 0.78, blue: 0.52),
                                    Color(red: 0.12, green: 0.62, blue: 0.98)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Shine effect
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.30),
                                    .clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.45),
                                    .white.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(color: Color(red: 0.12, green: 0.62, blue: 0.98).opacity(0.35), radius: 20, y: 12)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Démarrer le round suivant")
        .accessibilityHint("Round \(game.round + 1)")
    }
    
    private var backToHomeButton: some View {
        Button {
            Haptics.impact(.light)
            game.backToHome()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "house.fill")
                    .font(.system(size: 16, weight: .bold))
                
                Text("Retour à l'accueil")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.06))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.white.opacity(0.22), .white.opacity(0.08)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Retourner à l'accueil")
        .accessibilityHint("Quitter la partie en cours")
    }
}

