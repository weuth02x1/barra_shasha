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

    // فليب 3D واضح—يشتغل فقط عند الضغط على "تم"
    @State private var flipAngle: Double = 0
    @State private var isFlipping: Bool = false
    @State private var frontText: String = ""   // يظهر قبل 90°

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

                // شريط المسار + القطة (رصاصي)
                ProgressRowSolid(
                    completed: completed,
                    totalSteps: dailyLimit,
                    bowlImageName: bowlImageName,
                    catImageName: catImageName
                )

                Spacer()

                // الكارد
                if let task = currentTask {
                    ZStack {
                        // خلفية الكارد
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

                        // المحتوى الأمامي (قبل التبديل)
                        Text(frontText)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                            .opacity(flipAngle < 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(flipAngle), axis: (x: 0, y: 1, z: 0), perspective: 0.55)

                        // المحتوى الخلفي (بعد التبديل)
                        Text(task)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                            .opacity(flipAngle >= 90 ? 1 : 0)
                            .rotation3DEffect(.degrees(flipAngle - 180), axis: (x: 0, y: 1, z: 0), perspective: 0.55)

                        // زر "بسويها بعدين" (بدون فليب)
                        VStack {
                            HStack {
                                Button(action: { skipNoFlip() }) {
                                    Text("بسويها بعدين")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.white.opacity(0.18))
                                        .clipShape(Capsule())
                                }
                                .disabled(isFlipping)
                                Spacer()
                            }
                            .padding(14)
                            Spacer()
                        }

                        // زر "تم" (يفعل الفليب فقط)
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: { completeWithFlip() }) {
                                    Text("تم")
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.white.opacity(0.20))
                                        .clipShape(Capsule())
                                }
                                .disabled(isFlipping)
                                .padding(12)
                            }
                        }
                    }
                    .frame(width: 300, height: 380)
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
            frontText = ""
            return
        }
        let count = min(dailyLimit, pool.count)
        todaysTasks = Array(pool.shuffled().prefix(count))
        currentIndex = 0
        completed = 0
        frontText = todaysTasks.first ?? ""
    }

    // فليب أنيق (يُستدعى فقط عند "تم")
    private func runFlipAnimation(halfAction: @escaping () -> Void) {
        guard !isFlipping else { return }
        isFlipping = true
        frontText = currentTask ?? ""

        // 0 → 90 (إخفاء الأمامي)
        withAnimation(.easeInOut(duration: 0.22)) {
            flipAngle = 90
        }

        // بدّل المهمة عند 90°
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            halfAction()

            // 90 → 180 (إظهار الخلفي)
            withAnimation(.easeInOut(duration: 0.22)) {
                flipAngle = 180
            }

            // رجّع الزاوية للصفر للتجهيز للفليب التالي
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
                flipAngle = 0
                frontText = currentTask ?? ""
                isFlipping = false
            }
        }
    }

    // "تم" → فليب + تقدم
    private func completeWithFlip() {
        guard !todaysTasks.isEmpty, completed < dailyLimit else { return }
        runFlipAnimation {
            completed += 1
            todaysTasks.remove(at: currentIndex)
            if todaysTasks.isEmpty { return }
            if currentIndex >= todaysTasks.count { currentIndex = 0 }
        }
    }

    // "بسويها بعدين" → بدون فليب (فقط تدوير القائمة)
    private func skipNoFlip() {
        guard !todaysTasks.isEmpty, !isFlipping else { return }
        let skipped = todaysTasks.remove(at: currentIndex)
        todaysTasks.append(skipped)
        if currentIndex >= todaysTasks.count { currentIndex = 0 }
        frontText = currentTask ?? ""
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

// MARK: - Progress Row (رصاصي + قطة أسرع)
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
                // إطار المسار — رصاصي
                Capsule()
                    .strokeBorder(Color.gray.opacity(0.40), lineWidth: 2)
                    .frame(width: trackWidth, height: trackHeight)

                // التقدّم الحالي
                let progress = CGFloat(min(max(completed, 0), totalSteps - 1)) / CGFloat(max(totalSteps - 1, 1))
                let filledWidth = progress * (trackWidth - trackHeight) + trackHeight

                // تعبئة المسار — رصاصي وأبطأ
                HStack { Spacer() }
                    .background(
                        Capsule()
                            .fill(Color.gray.opacity(0.30))
                            .frame(width: filledWidth, height: trackHeight)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .animation(.easeInOut(duration: 0.6), value: completed)
                    )
                    .frame(width: trackWidth, height: trackHeight)

                // موضع القطة — أسرع
                let startX = trackWidth - trackHeight/2
                let catCenterXInRow = startX - progress * (trackWidth - trackHeight)

                Image(uiImage: UIImage(named: catImageName) ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: catSize, height: catSize)
                    .position(x: catCenterXInRow, y: rowHeight/2)
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
        return p;
    }
}

private extension View {
    func alignBottom() -> some View {
        self.frame(maxHeight: .infinity, alignment: .bottom)
    }
}
