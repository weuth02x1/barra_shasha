import SwiftUI

// MARK: - CardView
struct CardView: View {
    // الفئة المختارة قادمة من الهوم
    let category: String

    // نستخدمها للرجوع (بدل زر Back الافتراضي)
    @Environment(\.dismiss) private var dismiss

    // MARK: - Theme & Assets
    private let brandGreen = Color(red: 129/255, green: 204/255, blue: 187/255) // #81CCBB
    private let bgImageName = "background"
    private let bowlImageName = "food"   // ← غيّريها حسب أصولك
    private let catImageName  = "Cat"    // ← غيّريها حسب أصولك
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

    // مفاتيح الأنيميشن لحركة “شِمّة فليب”
    @State private var taskKey: UUID = .init()
    @State private var flipPhase: Double = 0 // 0 → 1 → 0

    var body: some View {
        ZStack {
            brandGreen.ignoresSafeArea()
                .overlay(Image(bgImageName).resizable().scaledToFill().opacity(0.15).ignoresSafeArea())

            VStack(spacing: 14) {

                // شريط علوي (سهمك أنت + Home)
                HStack {
                    topButton(system: "chevron.backward") { dismiss() } // يرجع فعلياً
                    Spacer()
                    topButtonImage(name: homeImageName) { dismiss() }     // أو قدميه لاحقاً لهوم حقيقية
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // عنوان الفئة
                Text("مهام \(category)")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.95))

                // العداد
                Text("\(completed)/\(dailyLimit)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white.opacity(0.95))

                // شريط المسار + القطة
                ProgressRowSolid(
                    completed: completed,
                    totalSteps: dailyLimit,
                    bowlImageName: bowlImageName,
                    catImageName: catImageName
                )

                Spacer()

                // الكارد
                if let task = currentTask {
                    let tiltDegrees = sin(flipPhase * .pi) * 12
                    let scale = 1 - 0.02 * sin(flipPhase * .pi)

                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.55), lineWidth: 1.4))
                            .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)

                        // موجة خفيفة
                        WaveShape()
                            .fill(Color.white.opacity(0.10))
                            .frame(height: 120)
                            .padding(.horizontal, 6)
                            .padding(.bottom, 6)
                            .alignBottom()

                        // زر "بسويها بعدين"
                        VStack {
                            HStack {
                                Button(action: { skipWithFlipLike() }) {
                                    Text("بسويها بعدين")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.18))
                                        .clipShape(Capsule())
                                }
                                Spacer()
                            }
                            .padding(14)
                            Spacer()
                        }

                        // نص المهمة
                        Text(task)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                            .id(taskKey)
                            .opacity(1 - 0.7 * (1 - (abs(0.5 - flipPhase) * 2)))
                            .rotation3DEffect(.degrees(-tiltDegrees), axis: (x: 0, y: 1, z: 0))
                            .animation(.easeInOut(duration: 0.35), value: taskKey)

                        // زر "تم"
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: { completeCurrent() }) {
                                    Text("تم")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.20))
                                        .clipShape(Capsule())
                                }
                                .padding(12)
                            }
                        }
                    }
                    .frame(width: 300, height: 380)
                    .rotation3DEffect(.degrees(tiltDegrees), axis: (x: 0, y: 1, z: 0))
                    .scaleEffect(scale)
                    .animation(.easeInOut(duration: 0.35), value: flipPhase)
                } else {
                    // حالة لا توجد مهام
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                        Text("لا توجد مهام لهذه الفئة بعد")
                            .foregroundStyle(.white.opacity(0.95))
                    }
                }

                Spacer(minLength: 24)
            }
        }
        .onAppear { setupToday() }
        .navigationBarBackButtonHidden(true)      // نخفي Back الافتراضي
        .toolbar(.hidden, for: .navigationBar)    // نخفي شريط العنوان الافتراضي
    }

    // MARK: - Logic
    private var currentTask: String? {
        guard !todaysTasks.isEmpty, currentIndex < todaysTasks.count else { return nil }
        return todaysTasks[currentIndex]
    }

    private func setupToday() {
        let pool = allTasksForCategory
        guard !pool.isEmpty else {
            todaysTasks = []; currentIndex = 0; completed = 0
            taskKey = .init(); flipPhase = 0
            return
        }
        let count = min(dailyLimit, pool.count)
        todaysTasks = Array(pool.shuffled().prefix(count))
        currentIndex = 0
        completed = 0
        taskKey = .init()
        flipPhase = 0
    }

    private func runFlipLikeAnimation(halfAction: @escaping () -> Void) {
        let total = 0.35
        withAnimation(.easeInOut(duration: total)) { flipPhase = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + total/2) {
            halfAction()
            taskKey = .init()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + total) {
            flipPhase = 0
        }
    }

    private func skipWithFlipLike() {
        guard !todaysTasks.isEmpty else { return }
        runFlipLikeAnimation {
            let skipped = todaysTasks.remove(at: currentIndex)
            todaysTasks.append(skipped)
            if currentIndex >= todaysTasks.count { currentIndex = 0 }
        }
    }

    private func completeCurrent() {
        guard !todaysTasks.isEmpty, completed < dailyLimit else { return }
        runFlipLikeAnimation {
            completed += 1
            todaysTasks.remove(at: currentIndex)
            if todaysTasks.isEmpty { return }
            if currentIndex >= todaysTasks.count { currentIndex = 0 }
        }
    }

    // MARK: - Top buttons helpers
    private func topButton(system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.18)))
        }
    }

    private func topButtonImage(name: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            imageOrSystem(named: name, fallback: "house.fill")
                .frame(width: 24, height: 24)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.18)))
        }
    }

    private func imageOrSystem(named: String, fallback: String) -> some View {
        Group {
            if UIImage(named: named) != nil {
                Image(named).resizable().scaledToFit()
            } else {
                Image(systemName: fallback).resizable().scaledToFit().foregroundStyle(.white)
            }
        }
    }
}

// MARK: - Progress Row (خط واحد متصل) + حركة القطة
private struct ProgressRowSolid: View {
    let completed: Int
    let totalSteps: Int
    let bowlImageName: String
    let catImageName: String

    private let foodSize: CGFloat   = 50
    private let catSize: CGFloat    = 60
    private let trackWidth: CGFloat = 300
    private let trackHeight: CGFloat = 12
    private let rowHeight: CGFloat  = 44

    var body: some View {
        HStack(spacing: 12) {
            imageOrSystem(named: bowlImageName, fallback: "takeoutbag.and.cup.and.straw.fill")
                .frame(width: foodSize, height: foodSize)

            ZStack {
                Capsule()
                    .strokeBorder(Color.white.opacity(0.75), lineWidth: 2)
                    .frame(width: trackWidth, height: trackHeight)

                let progress = CGFloat(min(max(completed, 0), totalSteps - 1)) / CGFloat(max(totalSteps - 1, 1))
                let filledWidth = progress * (trackWidth - trackHeight) + trackHeight

                HStack { Spacer() }
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: filledWidth, height: trackHeight)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                    .frame(width: trackWidth, height: trackHeight)

                let startX = trackWidth - trackHeight/2
                let catCenterXInRow = startX - progress * (trackWidth - trackHeight)

                Image(uiImage: UIImage(named: catImageName) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: catSize, height: catSize)
                    .position(x: catCenterXInRow, y: rowHeight/2)
                    .animation(.easeInOut(duration: 0.25), value: completed)
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
                Image(named).resizable().scaledToFit().foregroundStyle(.white)
            } else {
                Image(systemName: fallback).resizable().scaledToFit().foregroundStyle(.white)
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
