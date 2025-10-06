//
//  Theme.swift
//  Team 15
//
//  Created by Ruba Alghamdi on 13/04/1447 AH.
//

// Theme.swift
import SwiftUI
import AVFoundation

// MARK: - App Theme
struct AppTheme {
    // Colors
    static let primaryColor = Color(red: 129/255, green: 204/255, blue: 187/255)
    static let secondaryColor = Color(red: 146/255, green: 227/255, blue: 213/255)
    static let titleFont = Font.headline.weight(.bold)
    static let accentColor = Color.white.opacity(0.25)

    // Fonts
    static func beiruti(size: CGFloat) -> Font {
        .custom("Beiruti-VariableFont_wght", size: size)
    }

    static func playpen(size: CGFloat, weight: String = "Regular") -> Font {
        .custom("Playpen_\(weight)", size: size)
    }
}

// MARK: - Sound Manager
class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?

    func playClick() {
        guard let url = Bundle.main.url(forResource: "click", withExtension: "wav") else {
            print("⚠️ click.wav not found in bundle")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.play()
        } catch {
            print("⚠️ Error playing sound: \(error.localizedDescription)")
        }
    }
}

// MARK: - Reusable Button
struct GlassyButton: View {
    var title: String
    var width: CGFloat = 150
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTheme.playpen(size: 20, weight: "Bold"))
                .foregroundColor(.white)
                .frame(width: width, height: 50)
                .background(
                    RadialGradient(
                        gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0)]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 100
                    )
                )
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
        }
    }
}


