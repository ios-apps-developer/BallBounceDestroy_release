import SpriteKit
import SwiftUI

struct GameView: View {
    @ObservedObject var musicManager = MusicManager.shared
    @EnvironmentObject var shopManager: ShopManager
    @EnvironmentObject var coordinator: GameCoordinator
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPaused = false
    @State private var scene: GameScene?
    @State private var nickname: String = "Player"
    @State private var selectedAvatar: String = "ava1"
    
    var scaleFactor: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 2.0 : 1.0
    }
    
    var body: some View {
        ZStack {
            if let scene = scene {
                SpriteView(scene: scene)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
            }

            HStack(spacing: 0) {
                Button {
                    dismiss()
                } label: {
                    Image("btn_home")
                        .resizable()
                        .frame(width: 42 * scaleFactor, height: 42 * scaleFactor)
                }
                Spacer()
                ZStack {
                    Image("bg_score")
                        .resizable()
                        .frame(width: 140 * scaleFactor, height: 42 * scaleFactor)
                    Text("\(coordinator.currentScore)")
                        .font(FontManager.h24)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                Button {
                    coordinator.activateBonus1()
                } label: {
                    Image("power_up_1")
                        .resizable()
                        .frame(width: 42 * scaleFactor, height: 42 * scaleFactor)
                        .grayscale(coordinator.isBonus1Disabled ? 1.0 : 0.0)
                        .opacity(coordinator.isBonus1Disabled ? 0.5 : 1.0)
                }
                Button {
                    coordinator.activateBonus2()
                } label: {
                    Image("power_up_2")
                        .resizable()
                        .frame(width: 42 * scaleFactor, height: 42 * scaleFactor)
                        .grayscale(coordinator.isBonus2Disabled ? 1.0 : 0.0)
                        .opacity(coordinator.isBonus2Disabled ? 0.5 : 1.0)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, 16 * scaleFactor)
            .padding(.vertical, 8 * scaleFactor)
            
            if coordinator.isGameOver {
                gameOverMenu
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            setupScene()
            loadUserData()
        }
    }

    private func setupScene() {
        coordinator.resetGame()

        let newScene = GameScene(shopManager: shopManager, coordinator: coordinator)
        newScene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        newScene.scaleMode = .resizeFill
        newScene.gameDelegate = coordinator
        newScene.isPaused = false
        scene = newScene

        isPaused = false
    }
    
    private var gameOverMenu: some View {
        ZStack {
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 30 * scaleFactor) {
                Text("GAME OVER")
                    .font(FontManager.h30)
                    .foregroundStyle(.white)
            
                Text("POINTS SCORED:")
                    .font(FontManager.h14)
                    .foregroundStyle(.white)
                
                Text("\(coordinator.currentScore)")
                    .font(FontManager.h24)
                    .foregroundStyle(.white)
                
                HStack(spacing: 24 * scaleFactor) {
                    ZStack {
                        Image("btn_price")
                            .resizable()
                            .frame(width: 118 * scaleFactor, height: 35 * scaleFactor)
                            .onTapGesture {
                                dismiss()
                                shopManager.balance += coordinator.currentScore
                            }
                        Text("HOME")
                            .font(FontManager.h16)
                            .foregroundStyle(.white)
                    }
                    ZStack {
                        Image("btn_price")
                            .resizable()
                            .frame(width: 118 * scaleFactor, height: 35 * scaleFactor)
                            .onTapGesture {
                                restartGame()
                                shopManager.balance += coordinator.currentScore
                            }
                        Text("RESTART")
                            .font(FontManager.h16)
                            .foregroundStyle(.white)
                    }
                }
            }
            .offset(y: 36 * scaleFactor)
            .frame(width: 360 * scaleFactor, height: 237 * scaleFactor)
            .background(
                Image("game_over_window")
                    .resizable()
                    .frame(width: 360 * scaleFactor, height: 237 * scaleFactor)
            )
        }
        .transition(.opacity)
        .animation(.linear, value: coordinator.isGameOver)
    }
    
    private func restartGame() {
        isPaused = false
        scene = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.setupScene()
        }
    }
    
    private func loadUserData() {
        let storedNickname = UserDefaults.standard.string(forKey: "nickname") ?? "Player"
        let storedAvatar = UserDefaults.standard.string(forKey: "selectedAvatar") ?? "ava1"
        nickname = storedNickname
        selectedAvatar = storedAvatar
    }
}
