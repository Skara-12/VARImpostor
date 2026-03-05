import SwiftUI

struct PremiumBackground: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate

            let breathe1 = (sin(t * 0.35) + 1) / 2
            let breathe2 = (sin(t * 0.22 + 1.2) + 1) / 2
            let driftX = 0.25 + 0.50 * breathe1
            let driftY = 0.30 + 0.40 * breathe2

            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.035, green: 0.045, blue: 0.10),
                        Color(red: 0.01, green: 0.02, blue: 0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    colors: [
                        Color(red: 0.05, green: 0.78, blue: 0.52).opacity(0.20 + 0.10 * breathe1),
                        Color(red: 0.05, green: 0.78, blue: 0.52).opacity(0.05),
                        Color.clear
                    ],
                    center: UnitPoint(x: driftX, y: driftY),
                    startRadius: 30,
                    endRadius: 520
                )
                .blendMode(.screen)

                RadialGradient(
                    colors: [
                        Color.cyan.opacity(0.12 + 0.08 * breathe2),
                        Color.blue.opacity(0.06),
                        Color.clear
                    ],
                    center: UnitPoint(x: 1.0 - driftX, y: 0.15 + 0.25 * breathe1),
                    startRadius: 20,
                    endRadius: 560
                )
                .blendMode(.screen)

                // micro tension: faint red glow (keep it subtle)
                RadialGradient(
                    colors: [
                        Color.red.opacity(0.045 + 0.03 * breathe2),
                        Color.clear
                    ],
                    center: UnitPoint(x: 0.45 + 0.20 * breathe1, y: 0.50 + 0.15 * breathe2),
                    startRadius: 40,
                    endRadius: 520
                )
                .blendMode(.screen)
                .opacity(0.45)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.022),
                                Color.white.opacity(0.00),
                                Color.white.opacity(0.016),
                                Color.white.opacity(0.00)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .rotationEffect(.degrees((t * 6).truncatingRemainder(dividingBy: 360)))
                    .scaleEffect(1.6)
                    .blendMode(.overlay)
                    .opacity(0.18)

                // vignette (slightly stronger for focus)
                RadialGradient(
                    colors: [
                        Color.clear,
                        Color.black.opacity(0.62)
                    ],
                    center: .center,
                    startRadius: 220,
                    endRadius: 820
                )
                .blendMode(.multiply)
            }
            .ignoresSafeArea()
        }
    }
}
