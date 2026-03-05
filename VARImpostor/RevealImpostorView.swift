import SwiftUI
import UIKit

struct RevealImpostorView: View {
    @EnvironmentObject var game: GameState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appear = false
    @State private var pulse = false
    @State private var revealed = false
    
    private var impostorNamesJoined: String {
        let names = game.impostorNames
        if names.isEmpty { return "—" }
        return names.joined(separator: " & ")
    }
    
    private var isPlural: Bool {
        game.impostorNames.count > 1
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 16)

            // Header avec icône
            VStack(spacing: 16) {
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
                        .overlay(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.12), .clear],
                                        startPoint: .top,
                                        endPoint: UnitPoint(x: 0.5, y: 0.6)
                                    )
                                )
                        )
                        .shadow(color: .black.opacity(0.30), radius: 20, y: 10)

                    Image(systemName: revealed ? "eye.fill" : "eye.slash.fill")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: revealed)
                }
                
                Text("Révélation")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.60), radius: 30, y: 16)
                    .shadow(
                        color: Color.red.opacity(pulse ? 0.35 : 0.18),
                        radius: pulse ? 45 : 25,
                        y: 0
                    )
                    .shadow(
                        color: Color.orange.opacity(pulse ? 0.20 : 0.10),
                        radius: pulse ? 35 : 18,
                        y: 0
                    )
                
                Text(isPlural ? "Les imposteurs étaient..." : "L'imposteur était...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
            }
            .scaleEffect(appear ? 1 : 0.92)
            .opacity(appear ? 1 : 0)
            
            // Card principale avec le nom
            impostorCard
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .scaleEffect(appear ? 1 : 0.90)
                .opacity(appear ? 1 : 0)
            
            Spacer(minLength: 8)

            // ✅ Bouton révéler (si pas encore révélé)
            if !revealed {
                revealButton
                    .padding(.horizontal, 18)
                    .transition(.scale.combined(with: .opacity))
            }

            // Bouton continuer (visible seulement après révélation)
            if revealed {
                continueButton
                    .padding(.horizontal, 18)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Spacer()
                .frame(height: 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                appear = true
            }
            
            // ✅ REMOVED: Auto-reveal - L'utilisateur doit cliquer sur le bouton
            
            // Pulse animation
            pulse = false
            if !reduceMotion {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }
        }
    }
    
    // MARK: - Impostor Card
    
    private var impostorCard: some View {
        let shape = RoundedRectangle(cornerRadius: 28, style: .continuous)
        
        return ZStack {
            // Background avec gradient
            shape.fill(.ultraThinMaterial)
                .overlay(
                    shape.fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.04, green: 0.10, blue: 0.22).opacity(0.90),
                                Color(red: 0.02, green: 0.08, blue: 0.18).opacity(0.94)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )
            
            // Glow effect
            shape
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.60, green: 0.05, blue: 0.10).opacity(revealed ? 0.18 : 0.0),
                            Color.clear
                        ],
                        center: UnitPoint(x: 0.5, y: 0.65),
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .blendMode(.screen)
            
            // Contenu
            VStack(spacing: 18) {
                Spacer()
                
                if revealed {
                    // Nom de l'imposteur révélé
                    Text(impostorNamesJoined)
                        .font(.system(size: 52, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.5)
                        .lineLimit(2)
                        .shadow(color: .white.opacity(pulse ? 0.50 : 0.30), radius: pulse ? 24 : 16, y: 0)
                        .shadow(color: Color.red.opacity(0.40), radius: 30, y: 0)
                        .padding(.horizontal, 28)
                        .transition(.scale(scale: 0.7).combined(with: .opacity))
                } else {
                    // État masqué
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 64, weight: .semibold))
                            .background(
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color.red.opacity(pulse ? 0.20 : 0.08),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 5,
                                            endRadius: 50
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(pulse ? 0.55 : 0.35),
                                        .white.opacity(pulse ? 0.35 : 0.20)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .scaleEffect(pulse ? 1.05 : 0.95)
                            .shadow(
                                color: Color.red.opacity(pulse ? 0.30 : 0.15),
                                radius: pulse ? 24 : 14,
                                y: 0
                            )

                        Text("???")
                            .font(.system(size: 52, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color.red.opacity(pulse ? 0.75 : 0.50),
                                        Color.orange.opacity(pulse ? 0.55 : 0.35)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .shadow(
                                color: Color.red.opacity(pulse ? 0.25 : 0.10),
                                radius: pulse ? 20 : 10,
                                y: 0
                            )
                    }
                    .transition(.scale(scale: 1.3).combined(with: .opacity))
                }
                
                Spacer()
            }
        }
        .clipShape(shape)
        .overlay(
            shape.stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(revealed ? 0.20 : 0.10),
                        .white.opacity(revealed ? 0.10 : 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1.5
            )
        )
        .shadow(color: .black.opacity(0.40), radius: 30, y: 15)
        .shadow(color: Color.red.opacity(revealed ? 0.25 : 0.0), radius: revealed ? 40 : 0, y: 0)
        .frame(height: 320)
        .animation(.spring(response: 0.5, dampingFraction: 0.78), value: revealed)
    }
    
    // MARK: - Reveal Button
    
    private var revealButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.78)) {
                revealed = true
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 18, weight: .bold))
                
                Text(isPlural ? "Révéler les imposteurs" : "Révéler l'imposteur")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    // Gradient rouge pour la révélation
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.75, green: 0.08, blue: 0.12),
                                    Color(red: 0.85, green: 0.25, blue: 0.08)
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
                                    .white.opacity(0.25),
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
                                    .white.opacity(0.40),
                                    .white.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(
                color: Color(red: 0.75, green: 0.08, blue: 0.12).opacity(pulse ? 0.55 : 0.35),
                radius: pulse ? 28 : 18,
                y: 12
            )
            .shadow(color: .black.opacity(0.30), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
        .scaleEffect(pulse ? 1.02 : 0.98)
    }
    
    // MARK: - Continue Button
    
    private var continueButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            game.goToDone()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18, weight: .bold))
                
                Text("Continuer")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                ZStack {
                    // Gradient principal (style brand)
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
                                    .white.opacity(0.25),
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
                                    .white.opacity(0.40),
                                    .white.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                }
            )
            .shadow(color: .black.opacity(0.30), radius: 18, y: 10)
        }
        .buttonStyle(.plain)
    }
}
