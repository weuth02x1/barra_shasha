//
//  celeb.swift
//  Team 15
//
//  Created by maha althwab on 13/04/1447 AH.
//

import SwiftUI
import AVKit

// شاشة عرض الفيديو
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

// شاشة ثانية (مثال)
struct FriendView: View {
    var body: some View {
        VStack {
            Text("صفحة جديدة 🎮")
                .font(.largeTitle)
                .bold()
                .padding()
            Text("هنا يكمل التطبيق ✨")
                .foregroundColor(.gray)
        }
        .navigationTitle("FriendView")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - شاشة البداية
struct celeb: View {
    private let player: AVPlayer = {
        let url = Bundle.main.url(forResource: "cat", withExtension: "mov")!
        let player = AVPlayer(url: url)

        // تكرار الفيديو
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { _ in
            player.seek(to: .zero)
            player.play()
        }

        player.play()
        return player
    }()

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

                    VideoPlayerView(player: player)
                        .frame(width: 250, height: 250)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(AppTheme.secondaryColor, lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8)

                    // ✅ استخدم الزر من Theme.swift
                    NavigationLink(destination: reflectionView()) {
                        GlassyButton(title: "متابعة", width: 200) {
                            SoundManager.shared.playClick()
                        }
                    }
                    .padding(.top, 20)
                }
            }
        }
    }
}

#Preview {
    celeb()
}
