import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var shopManager: ShopManager
    @Environment(\.dismiss) private var dismiss

    let items = [
        (imageName: "gun1", price: 0),
        (imageName: "gun2", price: 10000),
        (imageName: "gun3", price: 15000)
    ]

    var body: some View {
        ZStack {
            Image("bg_shop")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 1) {
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
                            .frame(width: 84, height: 40)
                        Text("Shop")
                            .font(FontManager.h18)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    ZStack {
                        Image("btn_bg")
                            .resizable()
                            .frame(width: 84, height: 40)
                        Text("\(shopManager.balance)")
                            .font(FontManager.h18)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)

                Spacer()

                VStack(spacing: 20) {
                    ForEach(items, id: \.imageName) { item in
                        ShopItemView(item: item)
                            .environmentObject(shopManager)
                    }
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ShopItemView: View {
    @EnvironmentObject var shopManager: ShopManager
    let item: (imageName: String, price: Int)

    var isSelected: Bool {
        shopManager.selectedSkin == item.imageName
    }

    var body: some View {
        ZStack {
            Image(item.imageName)
                .resizable()
                .frame(width: 335, height: 161)

            if shopManager.isOwned(imageName: item.imageName) {
                Button {
                    shopManager.selectSkin(imageName: item.imageName)
                } label: {
                    Text(isSelected ? "SELECTED" : "USE")
                        .font(FontManager.h16)
                        .padding()
                        .frame(width: 158, height: 37)
                        .background {
                            Image("btn_price")
                                .resizable()
                        }
                        .foregroundColor(.white)
                        .animation(.easeInOut, value: isSelected)
                }
                .offset(x: -76, y: 44)
            } else {
                Button {
                    shopManager.purchaseItem(imageName: item.imageName, price: item.price)
                } label: {
                    HStack {
                        Text("BUY")
                            .font(FontManager.h16)
                        Text("\(item.price)")
                            .font(FontManager.h16)
                    }
                    .padding()
                    .frame(width: 158, height: 37)
                    .background {
                        Image("btn_price")
                            .resizable()
                    }
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }
                .disabled(!shopManager.canAfford(price: item.price))
                .offset(x: -76, y: 44)
            }
        }
    }
}
