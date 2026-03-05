import SwiftUI
import UIKit

// MARK: - Glass card

struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.04, green: 0.14, blue: 0.24).opacity(0.85),
                                        Color(red: 0.02, green: 0.10, blue: 0.16).opacity(0.90)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                .white.opacity(0.22),
                                .white.opacity(0.06)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: .black.opacity(0.50), radius: 24, y: 14)
    }
}

// MARK: - Premium button

struct PremiumActionButton: View {
    let title: String
    let systemImage: String

    var gradient: LinearGradient = LinearGradient(
        colors: [Color.white.opacity(0.22), Color.white.opacity(0.10)],
        startPoint: .leading,
        endPoint: .trailing
    )

    var isEnabled: Bool = true
    var isPulsing: Bool = false

    let action: () -> Void

    @State private var pressed = false
    @State private var breathe = false

    var body: some View {
        Button {
            guard isEnabled else { return }
            Haptics.impact(.medium)
            action()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .bold))
                    .opacity(isEnabled ? 1 : 0.7)

                Text(title)
                    .font(.system(size: 17, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(buttonBackground)
            .overlay(buttonSheen)
            .overlay(buttonStroke)
            .shadow(color: .black.opacity(isEnabled ? 0.72 : 0.18), radius: 22, y: 14)
            .shadow(color: glowColor, radius: glowRadius, y: glowY)
            .scaleEffect(pressed ? 0.985 : 1.0)
            .opacity(isEnabled ? 1 : 0.40)
            .animation(.spring(response: 0.25, dampingFraction: 0.85), value: pressed)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard isEnabled else { return }
                    if !pressed { pressed = true }
                }
                .onEnded { _ in
                    pressed = false
                }
        )
        .onAppear { startBreathingIfNeeded() }
        .onChange(of: isPulsing) { _ in startBreathingIfNeeded() }
    }

    private func startBreathingIfNeeded() {
        guard isPulsing && isEnabled else {
            breathe = false
            return
        }
        breathe = false
        withAnimation(.easeInOut(duration: 1.15).repeatForever(autoreverses: true)) {
            breathe = true
        }
    }

    private var buttonBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(gradient.opacity(isEnabled ? 1 : 0.22))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [
                                .clear,
                                .black.opacity(0.30)
                            ],
                            center: .center,
                            startRadius: 18,
                            endRadius: 240
                        )
                    )
                    .blendMode(.multiply)
            )
    }

    private var buttonSheen: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        .white.opacity(pressed ? 0.06 : 0.10),
                        .clear,
                        .black.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .blendMode(.overlay)
            .opacity(isEnabled ? 1 : 0.3)
    }

    private var buttonStroke: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(isEnabled ? 0.30 : 0.08),
                        .white.opacity(isEnabled ? 0.14 : 0.05),
                        .clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }

    private var glowColor: Color {
        guard isEnabled && isPulsing else { return .clear }
        return Color(red: 0.10, green: 0.70, blue: 0.95).opacity(breathe ? 0.42 : 0.26)
    }

    private var glowRadius: CGFloat {
        guard isEnabled && isPulsing else { return 0 }
        return breathe ? 28 : 16
    }

    private var glowY: CGFloat {
        guard isEnabled && isPulsing else { return 0 }
        return breathe ? 16 : 10
    }
}

// MARK: - Premium transitions

private struct PremiumBlurScaleModifier: ViewModifier {
    let blur: CGFloat
    let scale: CGFloat
    let opacity: CGFloat

    func body(content: Content) -> some View {
        content
            .blur(radius: blur)
            .scaleEffect(scale)
            .opacity(opacity)
    }
}

extension AnyTransition {
    static var premiumIn: AnyTransition {
        .modifier(
            active: PremiumBlurScaleModifier(blur: 10, scale: 0.98, opacity: 0),
            identity: PremiumBlurScaleModifier(blur: 0, scale: 1, opacity: 1)
        )
    }

    static var premiumOut: AnyTransition {
        .modifier(
            active: PremiumBlurScaleModifier(blur: 10, scale: 0.98, opacity: 0),
            identity: PremiumBlurScaleModifier(blur: 0, scale: 1, opacity: 1)
        )
    }

    static func premiumSlide(direction: Edge) -> AnyTransition {
        .move(edge: direction).combined(with: .premiumIn)
    }
}

// MARK: - Haptics helper

enum Haptics {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
