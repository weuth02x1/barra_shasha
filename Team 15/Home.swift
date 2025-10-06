// HomeView.swift
import SwiftUI

struct HomeView: View {
    @State private var path = NavigationPath()
    @State private var selectedCharacter = "character1"
    @State private var showCharacterPicker = false
    @State private var tappedCharacter: Int? = nil
    @State private var overlayBounce = false
    @State private var selectedButton: String? = nil

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                AppTheme.primaryColor.ignoresSafeArea()

                VStack(spacing: 28) {
                    // MARK: - Character Picker Section
                    VStack(spacing: 10) {
                        Text("انقر لاختيار شخصيتك")
                            .font(AppTheme.beiruti(size: 20))
                            .foregroundColor(.white)

                        Image(selectedCharacter)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showCharacterPicker = true
                                    overlayBounce = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    overlayBounce = false
                                }
                            }
                    }

                    // MARK: - Interest Buttons
                    VStack(spacing: 10) {
                        Text("اختر اهتمامك:")
                            .font(AppTheme.playpen(size: 20))
                            .foregroundColor(.white)
                            .padding()

                        HStack(spacing: 10) {
                            GlassyButton(title: "ادبيات") { go("ادبيات") }
                            GlassyButton(title: "فنونيات") { go("فنونيات") }
                        }
                        HStack(spacing: 10) {
                            GlassyButton(title: "مطبخيات") { go("مطبخيات") }
                            GlassyButton(title: "مغامرات") { go("مغامرات") }
                        }
                        GlassyButton(title: "عشوائيات", width: 310) { go("عشوائيات") }
                    }
                }
                .padding()

                // MARK: - Character Picker Overlay
                if showCharacterPicker {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                            .onTapGesture {
                                SoundManager.shared.playClick()
                                closeOverlayWithBounce()
                            }

                        VStack(spacing: 20) {
                            HStack(spacing: 20) {
                                ForEach(1...4, id: \.self) { index in
                                    Image("character\(index)")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 79, height: 100)
                                        .background(
                                            RadialGradient(
                                                gradient: Gradient(colors: tappedCharacter == index
                                                    ? [Color.white.opacity(0.5), AppTheme.primaryColor.opacity(0)]
                                                    : [Color.clear, Color.white.opacity(0.2)]),
                                                center: .center,
                                                startRadius: 0,
                                                endRadius: 80
                                            )
                                        )
                                        .cornerRadius(60)
                                        .scaleEffect(tappedCharacter == index ? 1.1 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: tappedCharacter)
                                        .onTapGesture {
                                            SoundManager.shared.playClick()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                tappedCharacter = index
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                selectedCharacter = "character\(index)"
                                                tappedCharacter = nil
                                                closeOverlayWithBounce()
                                            }
                                        }
                                        .padding(.horizontal, -6)
                                }
                            }
                        }
                        .padding()
                        .frame(width: 350, height: 150)
                        .background(
                            RadialGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color.white, location: 0.0001),
                                    .init(color: AppTheme.secondaryColor.opacity(0.8), location: 1.5),
                                    .init(color: AppTheme.primaryColor, location: 1.0)
                                ]),
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding(.bottom, 200)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: overlayBounce)
                    }
                }
            }
            .navigationDestination(for: String.self) { category in
                CardView(category: category)
            }
        }
    }

    // MARK: - Navigation
    private func go(_ category: String) {
        SoundManager.shared.playClick()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedButton = category
        }
        path.append(category)
    }

    // MARK: - Overlay Close Animation
    private func closeOverlayWithBounce() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            overlayBounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            overlayBounce = false
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                showCharacterPicker = false
            }
        }
    }
}

#Preview {
    HomeView()
}
