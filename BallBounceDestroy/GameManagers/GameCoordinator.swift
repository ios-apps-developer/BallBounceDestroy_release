import SwiftUI

protocol GameSceneDelegate: AnyObject {
    func didUpdateScore(_ score: Int)
    func didEndGame(win: Bool, totalScore: Int)
    func activateBonus1()
    func activateBonus2()
}

class GameCoordinator: ObservableObject, GameSceneDelegate {
    @Published var isGameOver = false
    @Published var currentScore = 0
    
    @Published var isBonus1Active = false
    @Published var isBonus2Active = false
    @Published var isBonus1Disabled = false
    @Published var isBonus2Disabled = false

    func didUpdateScore(_ score: Int) {
        currentScore = score
    }

    func didEndGame(win: Bool, totalScore: Int) {
        isGameOver = true
        currentScore = totalScore
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        let currentDate = formatter.string(from: Date())
        
        let newEntry = LeaderBoardEntry(date: currentDate, score: totalScore)
        var leaderboard = loadLeaderBoard()
        leaderboard.append(newEntry)
        
        saveLeaderBoard(leaderboard)
    }

    private func loadLeaderBoard() -> [LeaderBoardEntry] {
        if let data = UserDefaults.standard.data(forKey: "LeaderBoard"),
           let decoded = try? JSONDecoder().decode([LeaderBoardEntry].self, from: data)
        {
            return decoded
        }
        return []
    }

    private func saveLeaderBoard(_ leaderboard: [LeaderBoardEntry]) {
        if let data = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(data, forKey: "LeaderBoard")
        }
    }

    private func formattedCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter.string(from: Date())
    }
    
    func resetGame() {
        isGameOver = false
        currentScore = 0
    }
    
    func activateBonus1() {
        guard !isBonus1Disabled else { return }
        
        isBonus1Active = true
        isBonus1Disabled = true
      
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isBonus1Active = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            self.isBonus1Disabled = false
        }
    }
    
    func activateBonus2() {
        guard !isBonus2Disabled else { return }
        
        isBonus2Active = true
        isBonus2Disabled = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.isBonus2Active = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            self.isBonus2Disabled = false
        }
    }
}
