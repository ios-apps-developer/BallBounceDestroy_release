import SwiftUI

struct LeaderBoardEntry: Codable, Identifiable {
    let id: UUID
    let date: String
    let score: Int

    init(date: String, score: Int) {
        self.id = UUID()
        self.date = date
        self.score = score
    }
}

struct LeaderBoardView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var leaderBoardData: [LeaderBoardEntry] = []

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
                            .frame(width: 210, height: 40)
                        Text("LEADERBOARD")
                            .font(FontManager.h18)
                            .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)

                Spacer()
                ZStack {
                    Image("leader_window")
                        .resizable()
                        .frame(width: 334, height: 494)

                    VStack(spacing: 0) {
                        HStack {
                            Text("DATE")
                                .font(FontManager.h16)
                                .foregroundColor(.white)
                                .frame(width: 120, alignment: .leading)

                            Spacer()

                            Text("WINNING")
                                .font(FontManager.h16)
                                .foregroundColor(.white)
                                .frame(width: 120, alignment: .trailing)
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 5)

                        Divider()
                            .background(Color.white.opacity(0.6))
                            .frame(width: 300)

                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(leaderBoardData) { data in
                                    HStack {
                                        Text(data.date)
                                            .font(FontManager.h16)
                                            .foregroundColor(.white)
                                            .frame(width: 120, alignment: .leading)

                                        Spacer()

                                        Text("\(data.score)")
                                            .font(FontManager.h16)
                                            .foregroundColor(.white)
                                            .frame(width: 120, alignment: .trailing)
                                    }
                                }
                            }
                            .padding(.top, 5)
                        }
                        .scrollIndicators(.hidden)
                        .frame(height: 400)
                    }
                    .frame(width: 300)
                }
                Spacer()
            }
        }
        .onAppear {
            loadLeaderBoard()
        }
        .navigationBarBackButtonHidden(true)
    }

    private func loadLeaderBoard() {
        if let data = UserDefaults.standard.data(forKey: "LeaderBoard"),
           let decoded = try? JSONDecoder().decode([LeaderBoardEntry].self, from: data)
        {
            leaderBoardData = decoded.sorted { $0.score > $1.score }
        }
    }
}

#Preview {
    LeaderBoardView()
}
