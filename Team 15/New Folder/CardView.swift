import SwiftUI

struct CardView: View {
    // MARK: - Theme & Assets
    private let brandGreen = Color(red: 129/255, green: 204/255, blue: 187/255) // #81CCBB
    private let bgImageName = "background"
    private let bowlImageName = "food"   // ← اسم صورة الأكل عندك
    private let catImageName  = "Cat"    // ← اسم صورة القطة عندك
    private let homeImageName = "home"

    // MARK: - Tasks (مثال)
    private let allTasks: [String] = [
        "🚶 امشِ حول البيت 7 دقائق",
        "🎨 ارسم بشكل عشوائي",
        "🙃 قل اسمك بالعكس 5 مرات",
        "📚 اقرأ 3 صفحات من كتاب",
        "🧩 كوّن شكل من أشياء الغرفة",
        "🧘‍♀️ ثبّت وضعية توازن 30 ثانية",
        "🥤 اشرب كوب ماء بتركيز",
        "🧺 ساعد في ترتيب ركن صغير",
        "🐱 قلد صوت حيوان مضحك 10 مرات",
        "🎬 امثل مشهد درامي 15 ثانية"
    ]

    // MARK: - State
    private let dailyLimit = 5
    @State private var todaysTasks: [String] = []
    @State private var currentIndex: Int = 0       // مؤشر المهمة المعروضة
    @State private var completed: Int = 0          // المنجَز من 5

    // مفاتيح الأنيميشن لحركة “شِمّة فليب”
    @State private var taskKey: UUID = .init()     // لتبديل النص
    @State private var flipPhase: Double = 0       // 0 → 1 → 0

    var body: some View {
        ZStack {
            brandGreen.ignoresSafeArea()
                .overlay(Image(bgImageName).resizable().scaledToFill().opacity(0.15).ignoresSafeArea())

            VStack(spacing: 14) {

                // شريط علوي
                HStack {
                    topButton(system: "chevron.backward") { /* رجوع */ }
                    Spacer()
                    topButtonImage(name: homeImageName) { /* الرئيسية */ }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                // ===== العداد فوق شريط المشي =====
                HStack {
                    Spacer()
                    Text("\(completed)/\(dailyLimit)")
                        .font(.headline).bold().foregroundStyle(.white)
                    Spacer()
                }
                .padding(.top, 4)

                // ===== شريط المشي (خط واحد متصل) + القطة =====
                ProgressRowSolid(
                    completed: completed,
                    totalSteps: dailyLimit,
                    bowlImageName: bowlImageName,
                    catImageName: catImageName
                )

                Spacer()

                // ===== الكارد =====
                if let task = currentTask {
                    // ميلان خفيف للكارد (شِمّة فليب): 0→1→0
                    let tiltDegrees = sin(flipPhase * .pi) * 12       // ذروة 12°
                    let scale = 1 - 0.02 * sin(flipPhase * .pi)       // تصغير خفي جداً

                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1.4)
                            )
                            .shadow(color: .black.opacity(0.16), radius: 14, x: 0, y: 8)

                        // موجة خفيفة بالأسفل
                        WaveShape()
                            .fill(Color.white.opacity(0.10))
                            .frame(height: 120)
                            .padding(.horizontal, 6)
                            .padding(.bottom, 6)
                            .alignBottom()

                        // بسويها بعدين
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

                        // نص المهمة — يتبدّل بمكانه (بدون دخول من يمين/يسار)
                        Text(task)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 22)
                            .id(taskKey)
                            .opacity(1 - 0.7 * (1 - (abs(0.5 - flipPhase) * 2)))// تلاشي حول المنتصف
                            .rotation3DEffect(.degrees(-tiltDegrees), axis: (x: 0, y: 1, z: 0)) // مضاد الميلان للنص
                            .animation(.easeInOut(duration: 0.35), value: taskKey)

                        // تم
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
                }

                Spacer(minLength: 24)
            }
        }
        .onAppear { setupToday() }
    }

    // MARK: - Logic
    private var currentTask: String? {
        guard !todaysTasks.isEmpty, currentIndex < todaysTasks.count else { return nil }
        return todaysTasks[currentIndex]
    }

    private func setupToday() {
        todaysTasks = Array(allTasks.shuffled().prefix(dailyLimit))
        currentIndex = 0
        completed = 0
        taskKey = .init()
        flipPhase = 0
    }

    // أنيميشن “شِمّة فليب”: ننفّذ تغيير البيانات بنصّ الحركة
    private func runFlipLikeAnimation(halfAction: @escaping () -> Void) {
        let total = 0.35
        withAnimation(.easeInOut(duration: total)) { flipPhase = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + total/2) {
            halfAction()
            taskKey = .init() // يبدّل النص في منتصف الحركة
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + total) {
            flipPhase = 0
        }
    }

    /// بسويها بعدين: رجّع المهمة لآخر اليوم بدون زيادة التقدم
    private func skipWithFlipLike() {
        guard !todaysTasks.isEmpty else { return }
        runFlipLikeAnimation {
            let skipped = todaysTasks.remove(at: currentIndex)
            todaysTasks.append(skipped)
            if currentIndex >= todaysTasks.count { currentIndex = 0 }
        }
    }

    /// تم: زِد التقدّم واحذف المهمة الحالية
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

//
// MARK: - Progress Row (خط واحد متصل) + حركة القطة
//
private struct ProgressRowSolid: View {
    let completed: Int          // 0..(totalSteps-1)
    let totalSteps: Int         // 5
    let bowlImageName: String
    let catImageName: String

    // ثوابت سهلة التعديل
    private let foodSize: CGFloat   = 50     // حجم الصحن يسار
    private let catSize: CGFloat    = 60     // حجم القطة
    private let trackWidth: CGFloat = 300    // طول المسار
    private let trackHeight: CGFloat = 12    // سماكة المسار
    private let rowHeight: CGFloat  = 44     // ارتفاع الحاوية

    var body: some View {
        HStack(spacing: 12) {
            // الصحن يسار
            imageOrSystem(named: bowlImageName, fallback: "takeoutbag.and.cup.and.straw.fill")
                .frame(width: foodSize, height: foodSize)

            ZStack {
                // خط واحد متصل (كبسولة طويلة)
                Capsule()
                    .strokeBorder(Color.white.opacity(0.75), lineWidth: 2)
                    .frame(width: trackWidth, height: trackHeight)

                // تعبئة الجزء المنجز (يمين → يسار)
                let progress = CGFloat(min(max(completed, 0), totalSteps - 1)) / CGFloat(max(totalSteps - 1, 1))
                let filledWidth = progress * (trackWidth - trackHeight) + trackHeight // حافظ على الحواف الدائرية
                HStack { Spacer() } // لمحاذاة التعبئة من اليمين
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.9))
                            .frame(width: filledWidth, height: trackHeight)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    )
                    .frame(width: trackWidth, height: trackHeight)

                // القطة: مركزها يمشي من يمين المسار إلى يساره
                let startX = trackWidth - trackHeight/2
                let endX   = trackHeight/2
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

#Preview { CardView() }
