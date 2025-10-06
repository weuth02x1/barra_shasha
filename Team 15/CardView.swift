import SwiftUI
import AVKit

struct CardView: View {
    let category: String
    let selectedCharacter: String
    @Environment(\.dismiss) private var dismiss

    private let bgImageName = "background"
    private let bowlImageName = "food"
    private let catImageName = "Cat"

    private let dailyLimit = 5
    @State private var todaysTasks: [String] = []
    @State private var currentIndex: Int = 0
    @State private var completed: Int = 0

    @State private var flipped: Bool = false
    @State private var rotation: Double = 0
    @State private var cardOffsetY: CGFloat = -30

    @State private var showCelebration = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.primaryColor
                    .ignoresSafeArea()
                    .overlay(
                        Image(bgImageName)
                            .resizable()
                            .scaledToFill()
                            .opacity(0.15)
                            .ignoresSafeArea()
                    )

                VStack(spacing: 20) {
                    // ===== Header =====
                    VStack(spacing: 16) {
                        HStack {
                            Button {
                                SoundManager.shared.playClick()
                                dismiss()
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.white.opacity(0.22))
                                    .clipShape(Circle())
                                    .shadow(radius: 2)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        VStack(spacing: 4) {
                            Text("مهام \(category)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("\(completed)/\(dailyLimit)")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.white)
                        }

                        ProgressRowSolid(
                            completed: completed,
                            totalSteps: dailyLimit,
                            bowlImageName: bowlImageName,
                            catImageName: catImageName
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    Spacer()

                    // ===== Card =====
                    if let task = currentTask {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(.ultraThinMaterial)
                                .background(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0)
                                        ]),
                                        center: .topLeading,
                                        startRadius: 0,
                                        endRadius: 100
                                    )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                                .frame(width: 320, height: 400)
                                .shadow(radius: 5)
                                .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                                .offset(y: cardOffsetY)
                                .onTapGesture { flipCard() }
                                .overlay(
                                    VStack(spacing: 24) {
                                        Spacer()
                                        Text(flipped ? task : "جاهز للمهمة؟")
                                            .font(.title3.weight(.bold))
                                            .foregroundColor(.white)
                                            .multilineTextAlignment(.center)
                                            .padding(.horizontal, 24)
                                            .padding(.top, 50)

                                        Spacer()

                                        HStack(spacing: 16) {
                                            GlassyButton(title: "بسويها بعدين", width: 130) {
                                                SoundManager.shared.playClick()
                                                skipNoFlip()
                                            }

                                            GlassyButton(title: "تم", width: 90) {
                                                SoundManager.shared.playClick()
                                                completeWithFlip()
                                            }
                                        }
                                        .padding(.bottom, 24)
                                    }
                                )
                        }
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "tray")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                            Text("لا توجد مهام بعد")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 40)
                }
            }
            .onAppear { setupToday() }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(isPresented: $showCelebration) {
                celeb(selectedCharacter: selectedCharacter)
            }
        }
    }

    // MARK: - Logic
    private var currentTask: String? {
        guard !todaysTasks.isEmpty, currentIndex < todaysTasks.count else { return nil }
        return todaysTasks[currentIndex]
    }

    private func setupToday() {
        todaysTasks = (0..<dailyLimit).map { _ in
            TaskGenerator.randomTask(for: category)
        }
        currentIndex = 0
        completed = 0
        flipped = false
        rotation = 0
    }

    private func flipCard() {
        withAnimation(.easeInOut(duration: 0.6)) {
            rotation += 180
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            flipped.toggle()
        }
    }

    private func completeWithFlip() {
        guard !todaysTasks.isEmpty, completed < dailyLimit else { return }
        flipCard()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            completed += 1
            if completed == dailyLimit {
                // 🎉 Trigger celebration
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    showCelebration = true
                }
            } else {
                todaysTasks.remove(at: currentIndex)
                todaysTasks.append(TaskGenerator.randomTask(for: category))
                if currentIndex >= todaysTasks.count { currentIndex = 0 }
                flipped = false
                rotation = 0
            }
        }
    }

    private func skipNoFlip() {
        guard !todaysTasks.isEmpty else { return }
        let skipped = todaysTasks.remove(at: currentIndex)
        todaysTasks.append(skipped)
        if currentIndex >= todaysTasks.count { currentIndex = 0 }
        flipped = false
        rotation = 0
    }
}

// MARK: - Progress Row
struct ProgressRowSolid: View {
    let completed: Int
    let totalSteps: Int
    let bowlImageName: String
    let catImageName: String

    private let foodSize: CGFloat = 50
    private let catSize: CGFloat = 80
    private let trackWidth: CGFloat = 270
    private let trackHeight: CGFloat = 12
    private let rowHeight: CGFloat = 44

    var body: some View {
        HStack(spacing: 12) {
            Image(bowlImageName)
                .resizable()
                .scaledToFit()
                .frame(width: foodSize, height: foodSize)
                .offset(x: 10)

            ZStack {
                Capsule()
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
                    .frame(width: trackWidth, height: trackHeight)

                let progress = CGFloat(min(max(completed, 0), totalSteps - 1)) / CGFloat(max(totalSteps - 1, 1))
                let filledWidth = progress * (trackWidth - trackHeight) + trackHeight

                Capsule()
                    .fill(AppTheme.secondaryColor)
                    .frame(width: filledWidth, height: trackHeight)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .animation(.easeInOut(duration: 0.6), value: completed)

                let startX = trackWidth - trackHeight / 2
                let catCenterX = startX - progress * (trackWidth - trackHeight)
                Image(catImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: catSize, height: catSize)
                    .position(x: catCenterX, y: rowHeight / 2)
                    .animation(.easeOut(duration: 0.2), value: completed)
            }
            .frame(width: trackWidth, height: rowHeight)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 18)
    }
}
