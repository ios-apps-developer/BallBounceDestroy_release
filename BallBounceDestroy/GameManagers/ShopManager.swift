import SwiftUI

class ShopManager: ObservableObject {
    @Published var balance: Int {
        didSet {
            saveToUserDefaults()
        }
    }

    @Published var ownedSkins: Set<String> {
        didSet {
            saveToUserDefaults()
        }
    }

    @Published var selectedSkin: String {
        didSet {
            saveToUserDefaults()
        }
    }

    private let balanceKey = "Balance"
    private let ownedSkinsKey = "OwnedSkins"
    private let selectedSkinKey = "SelectedSkin"

    init() {
        self.balance = UserDefaults.standard.integer(forKey: balanceKey)
        self.ownedSkins = Set(UserDefaults.standard.stringArray(forKey: ownedSkinsKey) ?? ["gun1"])
        self.selectedSkin = UserDefaults.standard.string(forKey: selectedSkinKey) ?? "gun1"

        if !ownedSkins.contains("gun1") {
            ownedSkins.insert("gun1")
            selectedSkin = "gun1"
        }

        saveToUserDefaults()
    }

    func purchaseItem(imageName: String, price: Int) {
        guard balance >= price, !ownedSkins.contains(imageName) else { return }
        balance -= price
        ownedSkins.insert(imageName)
        saveToUserDefaults()
    }

    func selectSkin(imageName: String) {
        guard ownedSkins.contains(imageName) else { return }
        selectedSkin = imageName
        saveToUserDefaults()
    }

    func isOwned(imageName: String) -> Bool {
        ownedSkins.contains(imageName)
    }

    func canAfford(price: Int) -> Bool {
        balance >= price
    }

    private func saveToUserDefaults() {
        UserDefaults.standard.set(balance, forKey: balanceKey)
        UserDefaults.standard.set(Array(ownedSkins), forKey: ownedSkinsKey)
        UserDefaults.standard.set(selectedSkin, forKey: selectedSkinKey)
    }
}
