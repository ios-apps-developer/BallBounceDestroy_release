import SwiftUI

struct OnboardingView: View {
    var onFinish: () -> Void
    @State private var currentPage = 1
    var body: some View {
        ZStack {
            Image("bg_onb")
                .resizable()
                .edgesIgnoringSafeArea(.all)
                .scaledToFill()
            VStack {
                if currentPage == 1 {
                    VStack(spacing: 40) {
                        Image("onb_page_1")
                            .resizable()
                            .frame(width: 334, height: 497)
                        Button(action: {
                            currentPage = 2
                        }) {
                            Image("btn_ok")
                                .resizable()
                                .frame(width: 118, height: 37)
                        }
                        .padding(.bottom, 32)
                    }

                } else {
                    VStack(spacing: 40) {
                        Image("onb_page_2")
                            .resizable()
                            .frame(width: 334, height: 497)
                        Button(action: {
                            UserDefaults.standard.set(true, forKey: "onboardDone")
                            onFinish()
                        }) {
                            Image("btn_ok")
                                .resizable()
                                .frame(width: 118, height: 37)
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }
}
