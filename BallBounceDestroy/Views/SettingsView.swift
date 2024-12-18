import SwiftUI

struct SettingsView: View {
    @ObservedObject var musicManager = MusicManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("bg_shop")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image("btn_back")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    ZStack {
                        Image("btn_bg")
                            .resizable()
                            .frame(width: 140, height: 40)
                        Text("SETTINGS")
                            .font(FontManager.h18)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)

                Spacer()

                ZStack {
                    Image("settings_window")
                        .resizable()
                        .frame(width: 334, height: 181)
                        .cornerRadius(10)

                    VStack(spacing: 30) {
                        HStack {
                            Image("sound_off")
                                .resizable()
                                .frame(width: 22, height: 18)
                            Slider(value: $musicManager.volume, in: 0 ... 1)
                                .accentColor(.purple)
                                .frame(width: 200)
                            Image("sound_on")
                                .resizable()
                                .frame(width: 22, height: 18)
                        }

                        HStack(spacing: 100) {
                            Text("VIBRATION")
                                .font(FontManager.h16)
                                .foregroundColor(.white)
                            Toggle("", isOn: $musicManager.isVibroOn)
                                .toggleStyle(SwitchToggleStyle(tint: .purple))
                                .labelsHidden()
                                .frame(width: 50)
                        }
                    }
                }
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
