import AudioToolbox
import AVFoundation
import CoreHaptics
import SwiftUI

class MusicManager: ObservableObject {
    static let shared = MusicManager()

    private var player: AVAudioPlayer?
    private let soundKey = "SoundOn"
    private let vibroKey = "VibroOn"
    private let volumeKey = "Volume"

    @Published var isSoundOn: Bool {
        didSet {
            UserDefaults.standard.set(isSoundOn, forKey: soundKey)
            if isSoundOn {
                playLoopingSound()
            } else {
                stopSound()
            }
        }
    }

    @Published var isVibroOn: Bool {
        didSet {
            UserDefaults.standard.set(isVibroOn, forKey: vibroKey)
        }
    }

    @Published var volume: Float {
        didSet {
            UserDefaults.standard.set(volume, forKey: volumeKey)
            player?.volume = volume
        }
    }

    private init() {
        self.isSoundOn = UserDefaults.standard.object(forKey: soundKey) as? Bool ?? true
        self.isVibroOn = UserDefaults.standard.object(forKey: vibroKey) as? Bool ?? true
        self.volume = UserDefaults.standard.object(forKey: volumeKey) as? Float ?? 0.5

        if isSoundOn {
            playLoopingSound()
        }
    }

    func playLoopingSound() {
        guard let url = Bundle.main.url(forResource: "music_game_bg", withExtension: "mp3") else { return }
        if player != nil { return }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = volume
            player?.prepareToPlay()
            player?.play()
        } catch {}
    }

    func stopSound() {
        player?.stop()
        player = nil
    }

    func triggerVibration() {
        guard isVibroOn else { return }
        DispatchQueue.main.async {
            if CHHapticEngine.capabilitiesForHardware().supportsHaptics {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
        }
    }
}
