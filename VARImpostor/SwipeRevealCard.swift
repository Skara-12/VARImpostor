import SwiftUI
import UIKit

struct SwipeRevealCard: View {
    let playerName: String
    let word: String
    let pulse: Bool
    let onReveal: () -> Void
    let onHideAndNext: () -> Void

    @State private var dragUp: CGFloat = 0
    @State private var hasRevealedOnce = false
    @State private var didHaptic = false

    // micro-animations
    @State private var arrowBounce = false
    @State private var iconPulse = false

    // Reveal drama
    @State private var revealScale: CGFloat = 0.93
    @State private var revealGlow: CGFloat = 0.0
    @State private var revealDim: Double = 0.0

    // ✨ SIMPLIFIED: Un seul état - activé ou non (pas besoin d'enum complexe)
    @State private var canAdvance = false
    @State private var advanceFade: Double = 0.0
    
    // ✨ NEW: Micro-interactions
    @State private var coverRotation: Double = 0.0
    @State private var wordBlur: CGFloat = 0.0
    @State private var buttonPulse = false

    // Tuning
    private let cardHeight: CGFloat = 480
    private let revealThreshold: CGFloat = 150
    private let maxLift: CGFloat = 310
    private let radius: CGFloat = 34

    private var isLifted: Bool { dragUp > 1 }
    
    // ✨ NEW: Computed progress for smoother animations
    private var revealProgress: CGFloat {
        min(1.0, dragUp / revealThreshold)
    }

    private var wordFontSize: CGFloat {
        let length = word.count
        switch length {
        case ..<10: return 64
        case 10..<16: return 52
        case 16..<22: return 42
        default: return 34
        }
    }

    var body: some View {
        // Main card view
        VStack(spacing: 16) {
            card
                .frame(height: cardHeight)
                .padding(.horizontal, 18)
                .task {
                    // ✨ OPTIMIZED: Use Task instead of onAppear for animations
                    await startIdleAnimations()
                }
            
            // ✅ Bouton de contrôle manuel
            actionButton
                .padding(.horizontal, 18)
        }
    }
    
    // ✨ NEW: Async animation starter (better performance)
    private func startIdleAnimations() async {
        arrowBounce = false
        iconPulse = false
        
        withAnimation(.easeInOut(duration: 0.95).repeatForever(autoreverses: true)) {
            arrowBounce = true
        }
        withAnimation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true)) {
            iconPulse = true
        }
    }

    // MARK: - Card

    private var card: some View {
        let baseShape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return ZStack {
            // Back layer - GRADIENT VERT SATURÉ ET ÉCLATANT
            baseShape
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.03, green: 0.08, blue: 0.18),
                            Color(red: 0.04, green: 0.12, blue: 0.20),
                            Color(red: 0.02, green: 0.09, blue: 0.16)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    // Glow radial au centre (plus blanc pour plus de luminosité)
                    // ✨ IMPROVED: Reactive to drag
                    RadialGradient(
                        colors: [
                            Color(red: 0.10, green: 0.40, blue: 0.80).opacity(0.12 + 0.06 * revealProgress),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 240
                    )
                    .blendMode(.screen)
                )
                .overlay(
                    baseShape
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(red: 0.05, green: 0.70, blue: 0.50).opacity(revealGlow * 0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 220
                            )
                        )
                        .blendMode(.screen)
                        .allowsHitTesting(false)
                )
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.clear],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.25)
                    )
                    .blendMode(.overlay)
                )

            // Dim on reveal (beaucoup moins fort)
            baseShape
                .fill(Color.black.opacity(revealDim * 0.2))
                .blendMode(.multiply)
                .allowsHitTesting(false)

            // Word layer - POSITIONNÉ PLUS BAS (visible quand cover est levé)
            VStack(spacing: 0) {
                Spacer() // ✨ FIX: Tout l'espace flexible en haut

                // Mot avec glow propre (sans ombre)
                Text(word)
                    .font(.system(size: wordFontSize, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(red: 0.55, green: 1.0, blue: 0.85), .white],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.40)
                    .shadow(color: .white.opacity(0.80 + 0.35 * revealGlow), radius: 40 + 22 * revealGlow, y: 0)
                    .blur(radius: wordBlur) // ✨ NEW: Word blur effect
                    .padding(.horizontal, 28)
                    .opacity(hasRevealedOnce ? 1 : 0)
                    .scaleEffect(hasRevealedOnce ? revealScale : 0.85)

                Spacer()
                    .frame(height: 180) // ✨ FIX: Ajusté à 180px pour repositionner dans le tiers supérieur
            }
            .allowsHitTesting(false)

            // COVER (sheet)
            cover(shape: baseShape)
                .offset(y: -dragUp)
                // ✅ keep it premium: natural shadow only, NO "black band" gradient overlay
                .shadow(
                    color: .black.opacity(isLifted ? 0.32 : 0.14),
                    radius: isLifted ? 22 : 14,
                    x: 0,
                    y: isLifted ? 14 : 10
                )
                .animation(.easeInOut(duration: 0.10), value: isLifted)
                .gesture(dragGesture)

            // Micro fade between players
            baseShape
                .fill(Color.black.opacity(advanceFade))
                .allowsHitTesting(false)
        }
        // ✅ single global clip => no seams/lines at corners
        .clipShape(baseShape)
        .overlay(baseShape.stroke(.white.opacity(0.12), lineWidth: 1))
        .shadow(color: .black.opacity(0.45), radius: 30, y: 18)
        // ✨ OPTIMIZED: Animations consolidées (meilleures performances)
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: revealScale)
        .animation(.easeOut(duration: 0.28), value: revealGlow)
        .animation(.easeInOut(duration: 0.15), value: revealDim)
        .animation(.easeInOut(duration: 0.12), value: advanceFade)
        .animation(.easeInOut(duration: 0.10), value: isLifted)
        .animation(.interpolatingSpring(stiffness: 300, damping: 25), value: coverRotation)
        .animation(.easeOut(duration: 0.2), value: wordBlur)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 3)
            .onChanged { v in
                let up = max(0, -v.translation.height)
                dragUp = min(maxLift, up)
                
                // ✨ NEW: Mise à jour de la rotation 3D en fonction du drag
                coverRotation = min(8.0, (dragUp / maxLift) * 8.0)

                if dragUp >= revealThreshold {
                    if !hasRevealedOnce {
                        triggerReveal()
                        onReveal()
                    }
                    if !didHaptic {
                        didHaptic = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                } else {
                    didHaptic = false
                }
            }
            .onEnded { _ in
                // ✅ CHANGEMENT: Plus de passage automatique, juste refermer la carte
                withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
                    dragUp = 0
                    coverRotation = 0
                }
            }
    }

    // MARK: - Cover

    private func cover(shape baseShape: RoundedRectangle) -> some View {
        let coverShape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        return ZStack {
            // Base gradient (plus clair et contrasté)
            coverShape
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.06, green: 0.14, blue: 0.28),  // Bleu-noir top
                            Color(red: 0.04, green: 0.20, blue: 0.22),  // Vert-bleu moyen
                            Color(red: 0.03, green: 0.15, blue: 0.18)   // Vert foncé bottom
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Field lines (lower opacity to kill "grid / square artifacts")
            FieldPattern()
                .opacity(0.09)
                .blendMode(.softLight)
                .clipShape(coverShape)

            // Vignette
            coverShape
                .fill(
                    RadialGradient(
                        colors: [.white.opacity(0.07), .clear, .black.opacity(0.22)],
                        center: .topLeading,
                        startRadius: 20,
                        endRadius: 520
                    )
                )
                .blendMode(.overlay)

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.28)],
                startPoint: UnitPoint(x: 0.5, y: 0.75),
                endPoint: .bottom
            )
            .blendMode(.multiply)
            .clipShape(coverShape)
            .allowsHitTesting(false)

            coverShape
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 0.15, green: 0.55, blue: 0.90).opacity(0.12),
                            Color.clear
                        ],
                        center: .top,
                        startRadius: 10,
                        endRadius: 280
                    )
                )
                .blendMode(.screen)
                .allowsHitTesting(false)

            VStack(spacing: 16) {
                Spacer(minLength: 18)

                // ✅ Badge supprimé - Plus clair et logique

                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 88, height: 88)
                        .overlay(
                            Circle().stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.35),
                                        .white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.2
                            )
                        )
                        .shadow(color: .black.opacity(0.25), radius: 12, y: 6)
                    Image(systemName: "sportscourt.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.35), radius: 12, y: 8)
                        .scaleEffect(iconPulse ? 1.02 : 0.98)
                }

                Text("Glisse pour révéler")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .tracking(0.5)
                    .foregroundStyle(.white)

                Image(systemName: "arrow.up")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white.opacity(0.92))
                    .offset(y: arrowBounce ? -6 : 4)
                    .opacity(arrowBounce ? 1 : 0.85)

                Spacer()
            }
            .padding(.horizontal, 18)
        }
        // ✅ IMPORTANT: keep cover perfectly aligned with card corners
        .clipShape(coverShape)
        .overlay(
            coverShape.stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(isLifted ? 0.35 : 0.28),
                        .white.opacity(isLifted ? 0.10 : 0.08),
                        .white.opacity(0.04)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.2
            )
        )
    }

    // MARK: - Button

    private var actionButton: some View {
        Button { handleButtonTap() } label: {
            HStack(spacing: 10) {
                Image(systemName: buttonIcon)
                    .font(.system(size: 16, weight: .bold))
                    .opacity(canAdvance ? 1 : 0.60)

                Text(buttonTitle)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.08, green: 0.62, blue: 0.44).opacity(canAdvance ? 0.55 : 0.10),
                                        Color(red: 0.10, green: 0.55, blue: 0.85).opacity(canAdvance ? 0.45 : 0.06)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .blendMode(.overlay)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(.white.opacity(canAdvance ? 0.25 : 0.14), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(canAdvance ? 0.30 : 0.14), radius: 18, y: 10)
            .shadow(color: Color(red: 0.05, green: 0.78, blue: 0.52).opacity(canAdvance ? 0.35 : 0), radius: 22, y: 8)
        }
        .buttonStyle(.plain)
        .disabled(!canAdvance)
        .opacity(canAdvance ? 1 : 0.35)
        .scaleEffect(canAdvance ? 1.0 : 1.0)
        .onChange(of: canAdvance) { oldValue, newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                    buttonPulse = true
                }
            }
        }
    }

    private var buttonTitle: String {
        canAdvance ? "Passe au suivant" : "Révèle d'abord"
    }

    private var buttonIcon: String {
        canAdvance ? "arrow.right.circle.fill" : "lock.fill"
    }

    private func handleButtonTap() {
        // ✨ SIMPLIFIED: Un seul clic pour passer au suivant
        guard canAdvance else { return }
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        Task {
            withAnimation(.easeInOut(duration: 0.12)) { advanceFade = 0.28 }
            try? await Task.sleep(nanoseconds: 120_000_000)
            
            await MainActor.run {
                resetReveal()
                onHideAndNext()
            }
            
            try? await Task.sleep(nanoseconds: 80_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.14)) { advanceFade = 0.0 }
            }
        }
    }

    // MARK: - Reveal helpers

    private func triggerReveal() {
        hasRevealedOnce = true
        canAdvance = true  // ✅ Active le bouton immédiatement après révélation

        revealScale = 0.85
        revealGlow = 0.0
        revealDim = 0.0
        wordBlur = 10.0 // ✨ NEW: Start blurred

        // ✨ OPTIMIZED: Use Task for sequencing
        Task {
            withAnimation(.easeInOut(duration: 0.18)) { revealDim = 0.15 }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                revealScale = 1.0
            }
            withAnimation(.easeOut(duration: 0.28)) {
                revealGlow = 1.0
                wordBlur = 0.0 // ✨ NEW: Clear blur
            }
            
            try? await Task.sleep(nanoseconds: 280_000_000)
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.22)) { revealGlow = 0.65 }
            }
        }
    }

    private func resetReveal() {
        hasRevealedOnce = false
        dragUp = 0
        didHaptic = false
        revealScale = 0.85
        revealGlow = 0.0
        revealDim = 0.0
        canAdvance = false  // ✅ Désactive le bouton pour le prochain joueur
        coverRotation = 0.0
        wordBlur = 0.0
    }
}

// MARK: - Field pattern

private struct FieldPattern: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let inset: CGFloat = 26

            Path { p in
                p.addRoundedRect(
                    in: CGRect(x: inset, y: inset, width: w - 2*inset, height: h - 2*inset),
                    cornerSize: CGSize(width: 26, height: 26)
                )

                p.move(to: CGPoint(x: w/2, y: inset))
                p.addLine(to: CGPoint(x: w/2, y: h - inset))

                let r: CGFloat = min(w, h) * 0.12
                p.addEllipse(in: CGRect(x: w/2 - r, y: h/2 - r, width: 2*r, height: 2*r))

                let boxW: CGFloat = (w - 2*inset) * 0.32
                let boxH: CGFloat = (h - 2*inset) * 0.18

                p.addRoundedRect(
                    in: CGRect(x: inset, y: h/2 - boxH/2, width: boxW, height: boxH),
                    cornerSize: CGSize(width: 16, height: 16)
                )

                p.addRoundedRect(
                    in: CGRect(x: w - inset - boxW, y: h/2 - boxH/2, width: boxW, height: boxH),
                    cornerSize: CGSize(width: 16, height: 16)
                )
            }
            .stroke(
                Color.white.opacity(0.85),
                style: StrokeStyle(lineWidth: 0.8, lineCap: .round, lineJoin: .round, miterLimit: 1)
            )
        }
    }
}

// MARK: - Per-corner shape (kept in case you reuse it elsewhere)

private struct RoundedCornersShape: Shape {
    var topLeft: CGFloat
    var topRight: CGFloat
    var bottomLeft: CGFloat
    var bottomRight: CGFloat

    func path(in rect: CGRect) -> Path {
        let tl = min(min(topLeft, rect.width/2), rect.height/2)
        let tr = min(min(topRight, rect.width/2), rect.height/2)
        let bl = min(min(bottomLeft, rect.width/2), rect.height/2)
        let br = min(min(bottomRight, rect.width/2), rect.height/2)

        var p = Path()
        p.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))

        p.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        p.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                 radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)

        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        p.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                 radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)

        p.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        p.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                 radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)

        p.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        p.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                 radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)

        p.closeSubpath()
        return p
    }
}

