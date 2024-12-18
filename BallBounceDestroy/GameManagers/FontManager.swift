import SwiftUI

struct FontManager {
    static func boldLedBoard(size: CGFloat, weight: Font.Weight) -> Font {
        return .custom("SanasoftKladezBlack.kz", size: size).weight(weight)
    }

    static let h13 = boldLedBoard(size: 13, weight: .bold)
    static let h14 = boldLedBoard(size: 14, weight: .bold)
    static let h16 = boldLedBoard(size: 16, weight: .bold)
    static let h18 = boldLedBoard(size: 18, weight: .bold)
    static let h24 = boldLedBoard(size: 24, weight: .bold)
    static let h30 = boldLedBoard(size: 30, weight: .bold)
    static let h32 = boldLedBoard(size: 32, weight: .bold)
    static let h40 = boldLedBoard(size: 40, weight: .bold)
    static let h52 = boldLedBoard(size: 52, weight: .bold)
}
