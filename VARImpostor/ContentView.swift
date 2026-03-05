import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var game = GameState()

    var body: some View {
        ZStack {
            PremiumBackground()

            Group {
                switch game.phase {
                case .home:
                    HomeView_Minimalist()
                        .environmentObject(game)
                        .transition(.opacity)

                case .pack:
                    PackView()
                        .environmentObject(game)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .names:
                    NamesView()
                        .environmentObject(game)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .distribution:
                    DistributionView()
                        .environmentObject(game)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .revealImpostor:
                    RevealImpostorView()
                        .environmentObject(game)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))

                case .done:
                    DoneView()
                        .environmentObject(game)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.88), value: game.phase)
        }
    }
}

#Preview {
    ContentView()
}
