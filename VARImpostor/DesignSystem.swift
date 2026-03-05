import SwiftUI
import UIKit

// Brand colors (adjust to your exact values)
enum BrandColors {
    // ── Accent (boutons CTA, progress bars, glows) ──
    static let accentStart = Color(red: 0.05, green: 0.78, blue: 0.52)
    static let accentEnd   = Color(red: 0.12, green: 0.62, blue: 0.98)

    // ── Stroke (bordures des éléments actifs) ──
    static let strokeStart = Color(red: 0.10, green: 0.85, blue: 0.60)
    static let strokeEnd   = Color(red: 0.15, green: 0.60, blue: 0.95)

    // ── Background (fond général de l'app) ──
    static let backgroundBase  = Color(red: 0.02, green: 0.04, blue: 0.10)
    static let backgroundGlowTop = Color(red: 0.05, green: 0.35, blue: 0.28)
    static let backgroundGlowBot = Color(red: 0.08, green: 0.20, blue: 0.45)

    // ── Cards (glassmorphism bleu-nuit) ──
    static let cardTop    = Color(red: 0.04, green: 0.12, blue: 0.24)
    static let cardBottom = Color(red: 0.02, green: 0.10, blue: 0.18)

    // ── Révélation (bouton + glow imposteur) ──
    static let revealRed    = Color(red: 0.75, green: 0.08, blue: 0.12)
    static let revealOrange = Color(red: 0.85, green: 0.25, blue: 0.08)

    // ── Tile (éléments de liste non sélectionnés) ──
    static let tileFill        = Color.black.opacity(0.34)
    static let tileStrokeStart = Color.white.opacity(0.07)
    static let tileStrokeEnd   = Color.white.opacity(0.03)

    // ── Gradients prêts à l'emploi ──
    static var ctaGradient: LinearGradient {
        LinearGradient(
            colors: [accentStart, accentEnd],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var ctaGradientDiagonal: LinearGradient {
        LinearGradient(
            colors: [accentStart, accentEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var cardGradient: LinearGradient {
        LinearGradient(
            colors: [cardTop.opacity(0.88), cardBottom.opacity(0.92)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var revealGradient: LinearGradient {
        LinearGradient(
            colors: [revealRed, revealOrange],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var strokeGradient: LinearGradient {
        LinearGradient(
            colors: [strokeStart.opacity(0.55), strokeEnd.opacity(0.40)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// Design tokens for consistency
enum BrandMetrics {
    // ── Corner Radius ──
    static let cardRadius: CGFloat = 28
    static let buttonRadius: CGFloat = 22
    static let iconRadius: CGFloat = 12
    static let tileRadius: CGFloat = 16
    static let coverRadius: CGFloat = 34
    static let pillRadius: CGFloat = 100  // capsule

    // ── Opacités texte ──
    static let textPrimary: Double   = 1.0
    static let textSecondary: Double = 0.65
    static let textTertiary: Double  = 0.40
    static let textDisabled: Double  = 0.25

    // ── Opacités stroke ──
    static let strokeActive: Double   = 0.22
    static let strokeInactive: Double = 0.12
    static let strokeSubtle: Double   = 0.06

    // ── Opacités overlay ──
    static let overlayLight: Double  = 0.08
    static let overlayMedium: Double = 0.50
    static let overlayHeavy: Double  = 0.85

    // ── Spacing ──
    static let screenPadding: CGFloat = 18
    static let cardPadding: CGFloat   = 24
    static let rowPadding: CGFloat    = 16

    // ── Animation ──
    static let springResponse: Double      = 0.45
    static let springDamping: Double       = 0.85
    static let pulseSpeed: Double          = 1.35
    static let transitionDuration: Double  = 0.20

    // ── Legacy (garde pour compatibilité) ──
    static let tileCornerRadius: CGFloat   = 16
    static let iconCornerRadius: CGFloat   = 12
    static let selectionBarWidth: CGFloat  = 3
    static let noiseTileOpacity: Double    = 0.06
    static let noiseCTAOpacity: Double     = 0.06
}

enum BrandFonts {
    static func heroTitle(size: CGFloat = 48) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func sectionTitle(size: CGFloat = 36) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }

    static func buttonLabel(size: CGFloat = 17) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func bodyBold(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func caption(size: CGFloat = 13) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func statValue(size: CGFloat = 28) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
}

// Convenience image that tries a custom asset first, then falls back to an SF Symbol
struct BrandedIcon: View {
    enum Source {
        case asset(String)
        case system(String)
    }

    let preferred: Source
    let fallback: Source
    let size: CGFloat
    let weight: Font.Weight
    let color: Color

    var body: some View {
        Group {
            if case let .asset(name) = preferred, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .scaledToFit()
            } else {
                switch fallback {
                case let .asset(name):
                    Image(name)
                        .resizable()
                        .scaledToFit()
                case let .system(symbol):
                    Image(systemName: symbol)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                }
            }
        }
        .frame(width: size, height: size)
        .foregroundStyle(color)
    }
}
