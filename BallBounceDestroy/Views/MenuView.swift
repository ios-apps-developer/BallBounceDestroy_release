import SwiftUI

struct MenuView: View {
    @ObservedObject var musicManager = MusicManager.shared
    @State private var animationProgress: CGFloat = 0
    var scaleFactor: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 1.5 : 1.0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("bg_menu")
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()

                VStack(spacing: 140 * scaleFactor) {
                    Image("btn_play")
                        .resizable()
                        .frame(width: 400 * scaleFactor, height: 300 * scaleFactor)
                        .hidden()

                    VStack(spacing: 12 * scaleFactor) {
                        NavigationLink(destination: GameView()) {
                            Image("btn_play")
                                .resizable()
                                .frame(width: 275 * scaleFactor, height: 80 * scaleFactor)
                        }
                        .offset(y: animationProgress < 0.5 ? -UIScreen.main.bounds.height : 0)
                        .opacity(animationProgress < 0.5 ? 0 : 1)
                        .animation(.easeOut(duration: 0.8).delay(0.2), value: animationProgress)

                        NavigationLink(destination: LeaderBoardView()) {
                            Image("btn_leaderboard")
                                .resizable()
                                .frame(width: 180 * scaleFactor, height: 38 * scaleFactor)
                        }
                        .offset(x: animationProgress < 0.7 ? UIScreen.main.bounds.width : 0)
                        .opacity(animationProgress < 0.7 ? 0 : 1)
                        .animation(.easeOut(duration: 0.8).delay(0.6), value: animationProgress)

                        NavigationLink(destination: ShopView()) {
                            Image("btn_shop")
                                .resizable()
                                .frame(width: 180 * scaleFactor, height: 38 * scaleFactor)
                        }
                        .offset(x: animationProgress < 0.7 ? -UIScreen.main.bounds.width : 0)
                        .opacity(animationProgress < 0.7 ? 0 : 1)
                        .animation(.easeOut(duration: 0.8).delay(0.8), value: animationProgress)

                        NavigationLink(destination: SettingsView()) {
                            Image("btn_settings")
                                .resizable()
                                .frame(width: 180 * scaleFactor, height: 38 * scaleFactor)
                        }
                        .offset(x: animationProgress < 0.7 ? UIScreen.main.bounds.width : 0)
                        .opacity(animationProgress < 0.7 ? 0 : 1)
                        .animation(.easeOut(duration: 0.8).delay(1.0), value: animationProgress)
                    }
                }
                .offset(y: -20)
                .padding(.vertical, 20 * scaleFactor)
                .padding(.horizontal, 16 * scaleFactor)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animationProgress = 1
                }
            }
        }
    }
}
