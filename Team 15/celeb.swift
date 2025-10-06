//
//  celeb.swift
//  Team 15
//
//  Created by maha althwab on 13/04/1447 AH.
//

import SwiftUI
import AVKit
import AVFoundation

// MARK: - Video Player View
struct VideoPlayerView: UIViewRepresentable {
    let player: AVPlayer

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.cornerRadius = 30
        playerLayer.masksToBounds = true
        view.layer.addSublayer(playerLayer)

        DispatchQueue.main.async {
            playerLayer.frame = view.bounds
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let layer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            layer.frame = uiView.bounds
        }
    }
}

// MARK: - Sound Manager
class SoundPlayer {
    static let shared = SoundPlayer()
    private var audioPlayer: AVAudioPlayer?

    func playSound(named soundName: String, type: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: type) else {
            print("⚠️ Sound file not found: \(soundName).\(type)")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = 0.9
            audioPlayer?.play()
        } catch {
            print("❌ Failed to play sound: \(error.localizedDescription)")
        }
    }
}

// MARK: - Celebration View
struct celeb: View {
    let selectedCharacter: String
    @State private var player: AVPlayer?

    // Selects the correct video based on character
    private func videoName(for character: String) -> String {
        switch character {
        case "character1": return "bear"
        case "character2": return "giraffe"
        case "character3": return "turtle"
        case "character4": return "cat"
        default: return "cat"
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.secondaryColor.ignoresSafeArea()
                Image("Imagem")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("ياي 🎉 انجزت مهامك!")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.6), radius: 4, x: 0, y: 2)

                    if let player = player {
                        VideoPlayerView(player: player)
                            .frame(width: 250, height: 250)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.white.opacity(0.6), lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 8)
                    }

                    // Continue Button
                    NavigationLink(destination: reflectionView()) {
                        GlassyButton(title: "متابعة", width: 200) {
                            SoundManager.shared.playClick()
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .onAppear {
                setupVideo()
                SoundPlayer.shared.playSound(named: "celebration", type: "wav")
            }
        }
    }

    // Initialize and loop video
    private func setupVideo() {
        let videoFileName = videoName(for: selectedCharacter)
        guard let url = Bundle.main.url(forResource: videoFileName, withExtension: "mov") else {
            print("⚠️ Missing video: \(videoFileName).mov")
            return
        }

        let newPlayer = AVPlayer(url: url)
        self.player = newPlayer

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: newPlayer.currentItem,
            queue: .main
        ) { _ in
            newPlayer.seek(to: .zero)
            newPlayer.play()
        }

        newPlayer.play()
    }
}

// MARK: - Preview
#Preview {
    celeb(selectedCharacter: "character1")
}
