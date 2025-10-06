import SwiftUI

// MARK: - CardView
struct CardView: View {
    let category: String
    @Environment(\.dismiss) private var dismiss

    // Assets / Theme
    private let bgImageName   = "background"
    private let bowlImageName = "food"
    private let catImageName  = "Cat"

    // بيانات المهام
    private var allTasksForCategory: [String] {
        tasksByCategory[category] ?? []
    }

    // حالة الصفحة
    private let dailyLimit = 5
    @State private var todaysTasks: [String] = []
    @State private var currentIndex: Int = 0
    @State private var completed: Int = 0

    // فليب الكارد
    @State private var flipAngle: Double = 0
    @State private var isFlipping: Bool = false
    @State private var frontText: String = ""

    // تحكّم يدوي بمكان الكارد
    @State private var cardOffsetY: CGFloat = -30

    var body: some View {
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
                        catImageName:  catImageName
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                // ===== Card =====
                if let task = currentTask {
                    ZStack {
                        // خلفية الكارد
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1.4)
                            )
                            .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)

                        // موجة ديكورية
                        WaveShape()
                            .fill(Color.white.opacity(0.10))
                            .frame(height: 120)
                            .padding(.horizontal, 6)
                            .padding(.bottom, 6)
                            .alignBottom()

                        // 👇 وجهان للنص بدون انعكاس مرآتي (الفليب نظيف)
                        ZStack {
                            let angle = flipAngle.truncatingRemainder(dividingBy: 360)

                            // الوجه الأمامي (لا يدور مع النص)
                            Text(frontText)
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 22)
                                .opacity((angle < 90 || angle > 270) ? 1 : 0)

                            // الوجه الخلفي (مقلوب 180° ثابتة)
                            Text(task)
                                .font(.title3.weight(.bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 22)
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0)) // ثابت
                                .opacity((angle >= 90 && angle <= 270) ? 1 : 0)
                        }

                        // ===== الأزرار ثابتة (ما تقلب) =====

                        // زر "بسويها بعدين" أعلى الكارد
                        VStack {
                            HStack {
                                GlassyButton(title: "بسويها بعدين", width: 150) {
                                    SoundManager.shared.playClick()
                                    skipNoFlip()
                                }
                                Spacer()
                            }
                            .padding(20)
                            Spacer()
                        }
                        .rotation3DEffect(.degrees(-flipAngle), axis: (x: 0, y: 1, z: 0))

                        // زر "تم" أسفل الكارد
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                GlassyButton(title: "تم", width: 110) {
                                    SoundManager.shared.playClick()
                                    completeWithFlip()
                                }
                            }
                            .padding(20)
                        }
                        .rotation3DEffect(.degrees(-flipAngle), axis: (x: 0, y: 1, z: 0))
                    }
                    .frame(width: 320, height: 400)
                    .padding(.horizontal, 24)
                    .offset(y: cardOffsetY) // تحريك الكارد يدويًا
                    .rotation3DEffect(.degrees(flipAngle),
                                      axis: (x: 0, y: 1, z: 0),
                                      perspective: 0.6) // الفليب للكارد نفسه فقط
                }

                Spacer(minLength: 40)
            }
        }
        .onAppear { setupToday() }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Logic
    private var currentTask: String? {
        guard !todaysTasks.isEmpty, currentIndex < todaysTasks.count else { return nil }
        return todaysTasks[currentIndex]
    }

    private func setupToday() {
        let pool = allTasksForCategory
        guard !pool.isEmpty else {
            todaysTasks = []
            currentIndex = 0
            completed  = 0
            frontText  = ""
            return
        }

        todaysTasks = Array(pool.shuffled().prefix(min(dailyLimit, pool.count)))
        currentIndex = 0
        completed  = 0
        frontText  = todaysTasks.first ?? ""
    }

    private func runFlipAnimation(halfAction: @escaping () -> Void) {
        guard !isFlipping else { return }
        isFlipping = true

        withAnimation(.easeInOut(duration: 0.22)) { flipAngle += 90 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            halfAction()
            withAnimation(.easeInOut(duration: 0.22)) { flipAngle += 90 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.44) {
                isFlipping = false
            }
        }
    }

    private func completeWithFlip() {
        guard !todaysTasks.isEmpty, completed < dailyLimit else { return }
        runFlipAnimation {
            completed += 1
            todaysTasks.remove(at: currentIndex)
            if todaysTasks.isEmpty { return }
            if currentIndex >= todaysTasks.count { currentIndex = 0 }
        }
    }

    private func skipNoFlip() {
        guard !todaysTasks.isEmpty, !isFlipping else { return }
        let skipped = todaysTasks.remove(at: currentIndex)
        todaysTasks.append(skipped)
        if currentIndex >= todaysTasks.count { currentIndex = 0 }
        frontText = currentTask ?? ""
    }
}

// MARK: - Progress Row (الصحن + الشريط + القطة) — يمين ➜ يسار
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
            // الصحن — تقدرين تحركينه بتغيير offset
            Image(bowlImageName)
                .resizable()
                .scaledToFit()
                .frame(width: foodSize, height: foodSize)
                .offset(x: 10)

            ZStack {
                // إطار المسار
                Capsule()
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 2)
                    .frame(width: trackWidth, height: trackHeight)

                // نسبة التقدم (0 → 1)
                let progress = CGFloat(min(max(completed, 0), totalSteps - 1)) / CGFloat(max(totalSteps - 1, 1))
                let filledWidth = progress * (trackWidth - trackHeight) + trackHeight

                // التعبئة من اليمين إلى اليسار
                Capsule()
                    .fill(AppTheme.secondaryColor)
                    .frame(width: filledWidth, height: trackHeight)
                    .frame(maxWidth: .infinity, alignment: .trailing) // اصطفاف يمين
                    .animation(.easeInOut(duration: 0.6), value: completed)

                // 🐱 القطة: من اليمين إلى اليسار
                let startX = trackWidth - trackHeight / 2                 // بداية يمين
                let catCenterX = startX - progress * (trackWidth - trackHeight) // تقل لين تروح يسار
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

// MARK: - موجة أسفل الكارد
struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let h = rect.height
        p.move(to: CGPoint(x: 0, y: h * 0.35))
        p.addCurve(
            to: CGPoint(x: rect.width, y: h * 0.15),
            control1: CGPoint(x: rect.width * 0.30, y: h * 0.00),
            control2: CGPoint(x: rect.width * 0.70, y: h * 0.45)
        )
        p.addLine(to: CGPoint(x: rect.width, y: h))
        p.addLine(to: CGPoint(x: 0, y: h))
        p.closeSubpath()
        return p
    }
}

private extension View {
    func alignBottom() -> some View {
        self.frame(maxHeight: .infinity, alignment: .bottom)
    }
}
