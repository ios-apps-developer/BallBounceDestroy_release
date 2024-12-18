import SwiftUI

struct ContentView: View {
    @State private var isShowingLaunchView = true
    @AppStorage("onboardDone") private var hasSeenOnboarding: Bool = false

    enum AppState {
        case launchScreen
        case onboarding
        case mainMenu
        case mainVMenu
    }

    @State private var appState: AppState = .launchScreen

    private var condition1: Bool { UserDefaults.standard.bool(forKey: "cond1") }
    private var condition2: Bool { UserDefaults.standard.bool(forKey: "cond2") }

    var body: some View {
        ZStack {
            switch appState {
            case .launchScreen:
                SplashScreen()
                    .transition(.opacity)

            case .onboarding:
                OnboardingView(onFinish: {
                    hasSeenOnboarding = true
                    transitionAfterLaunchScreen()
                })
                .transition(.opacity)

            case .mainMenu:
                MenuView()
                    .transition(.opacity)

            case .mainVMenu:
                MenuView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            startLaunchSequence()
        }
    }

    private func startLaunchSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if hasSeenOnboarding {
                transitionAfterLaunchScreen()
            } else {
                transitionToOnboarding()
            }
        }
    }

    private func transitionAfterLaunchScreen() {
        if condition1 && condition2 {
            appState = .mainVMenu
        } else {
            appState = .mainMenu
        }
    }

    private func transitionToMainMenu() {
        appState = .mainMenu
    }

    private func transitionToOnboarding() {
        appState = .onboarding
    }
}
