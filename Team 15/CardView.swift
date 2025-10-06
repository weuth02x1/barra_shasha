import SwiftUI

// MARK: - CardView
struct CardView: View {
    // الفئة المختارة قادمة من الهوم
    let category: String

    // نستخدمها للرجوع (بدل زر Back الافتراضي)
    @Environment(\.dismiss) private var dismiss

    // MARK: - Theme & Assets
    private let bgImageName = "background"
    private let bowlImageName = "food"
    private let catImageName = "Cat"
    private let homeImageName = "home"

    // مهام هذه الفئة من القاموس المشترك
    private var allTasksForCategory: [String] {
        tasksByCategory[category] ?? []
    }

    // MARK: - State
    private let dailyLimit = 5
    @State private var todaysTasks: [String] = []
    @State private var currentIndex: Int = 0
    @State private var completed: Int = 0
    @State private var flipAngle: Double = 0
    @State private var isFlipping: Bool = false
    @State private var frontText: String = ""

    // ✅ تحكّم يدوي بمكان الكارد (القيمة السالبة ترفعه، الموجبة تنزّله)
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
                // الهيدر: سهم رجوع + العنوان + شريط التقدم
                VStack(spacing: 16) {
                    // زر الرجوع
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

                    // العناوين
                    VStack(spacing: 4) {
                        Text("مهام \(category)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(completed)/\(dailyLimit)")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                    }

                    // شريط التقدّم
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

                // الكارد (المهام)
                if let task = currentTask {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1.4)
                            )
                            .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)

                        WaveShape()
                            .fill(Color.white.opacity(0.10))
                            .frame(height: 120)
                            .padding(.horizontal, 6)
                            .padding(.bottom, 6)
                            .alignBottom()

                        // الجهة الأمامية
                        Text(frontText)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                            .opacity(flipAngle < 90 ? 1 : 0)
                            .rotation3DEffect(
                                .degrees(flipAngle),
                                axis: (x: 0, y: 1, z: 0),
                                perspective: 0.55
                            )

                        // الجهة الخلفية
                        Text(task)
                            .font(.title3.weight(.bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                            .opacity(flipAngle >= 90 ? 1 : 0)
                            .rotation3DEffect(
                                .degrees(flipAngle - 180),
                                axis: (x: 0, y: 1, z: 0),
                                perspective: 0.55
                            )

                        // ✅ زر "بسويها بعدين" رجعناه فوق الكارد
                        VStack {
                            HStack {
                                GlassyButton(title: "بسويها بعدين", width: 150, action: {
                                    SoundManager.shared.playClick()
                                    skipNoFlip()
                                })
                                .font(.system(size: 15, weight: .semibold))
                                Spacer()
                            }
                            .padding(20)
                            Spacer()
                        }

                        // ✅ الزر السفلي "تم"
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                GlassyButton(title: "تم", width: 110, action: {
                                    SoundManager.shared.playClick()
                                    completeWithFlip()
                                })
                                .font(.system(size: 15, weight: .semibold))
                            }
                            .padding(20)
                        }
                    }
                    .frame(width: 320, height: 400)
                    .padding(.horizontal, 24)
                    .offset(y: cardOffsetY) // 👈 تحكم المكان من هنا
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
            completed = 0
            frontText = ""
            return
        }

        let count = min(dailyLimit, pool.count)
        todaysTasks = Array(pool.shuffled().prefix(count))
        currentIndex = 0
        completed = 0
        frontText = todaysTasks.first ?? ""
    }

    private func runFlipAnimation(halfAction: @escaping () -> Void) {
        guard !isFlipping else { return }
        isFlipping = true
        frontText = currentTask ?? ""

        withAnimation(.easeInOut(duration: 0.22)) { flipAngle = 90 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            halfAction()
            withAnimation(.easeInOut(duration: 0.22)) { flipAngle = 180 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                flipAngle = 0
                frontText = currentTask ?? ""
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

// MARK: - Progress Row
private struct ProgressRowSolid: View {
    let completed: Int
    let totalSteps: Int
    let bowlImageName: String
    let catImageName: String

    private let foodSize: CGFloat = 50
    private let catSize: CGFloat = 80
    private let trackWidth: CGFloat = 270
    private let trackHeight: CGFloat = 12
    private let rowHeight: CGFloat = 44
    static let secondaryColor = Color(red: 146/255, green: 227/255, blue: 213/255)

    var body: some View {
        HStack(spacing: 12) {
            imageOrSystem(named: bowlImageName, fallback: "takeoutbag.and.cup.and.straw.fill")
                .frame(width: foodSize, height: foodSize)
                .offset(x: 10) // ← السالب يحرّكه يسار، الموجب يحرّكه يمين
            ZStack {
                Capsule()
                    .strokeBorder(Color.white.opacity(0.60), lineWidth: 2)
                    .frame(width: trackWidth, height: trackHeight)

                let progress = CGFloat(min(max(completed, 0), totalSteps - 1)) / CGFloat(max(totalSteps - 1, 1))
                let filledWidth = progress * (trackWidth - trackHeight) + trackHeight

                HStack { Spacer() }
                    .background(
                        Capsule()
                            .fill(AppTheme.secondaryColor)
                            .frame(width: filledWidth, height: trackHeight)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .animation(.easeInOut(duration: 0.6), value: completed)
                    )
                    .frame(width: trackWidth, height: trackHeight)

                let startX = trackWidth - trackHeight / 2
                let catCenterXInRow = startX - progress * (trackWidth - trackHeight)
                Image(uiImage: UIImage(named: catImageName) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: catSize, height: catSize)
                    .position(x: catCenterXInRow, y: rowHeight / 2)
                    .animation(.easeOut(duration: 0.20), value: completed)
            }
            .frame(width: trackWidth, height: rowHeight)

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private func imageOrSystem(named: String, fallback: String) -> some View {
        Group {
            if UIImage(named: named) != nil {
                Image(named)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
            } else {
                Image(systemName: fallback)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
            }
        }
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
