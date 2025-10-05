import SwiftUI

struct homeView: View {
    // مسار التنقّل
    @State private var path = NavigationPath()

    // حالة اختيار الشخصية (لو حابة تبقينها)
    @State private var selectedCharacter = "character1"
    @State private var showCharacterPicker = false
    @State private var tappedCharacter: Int? = nil
    @State private var overlayBounce = false

    // تمييز الزر
    @State private var selectedButton: String? = nil

    // ألوانك
    private let primaryColor = Color(red: 129/255, green: 204/255, blue: 187/255)
    private let secondaryColor = Color(red: 146/255, green: 227/255, blue: 213/255)

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                primaryColor.ignoresSafeArea()

                VStack(spacing: 28) {
                    // اختيار الشخصية (اختياري)
                    VStack(spacing: 10) {
                        Text("انقر لاختيار شخصيتك:")
                            .font(.custom("Playpen_Bold", size: 20))
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

                    // اختيار الاهتمام
                    VStack(spacing: 10) {
                        Text("اختر اهتمامك:")
                            .font(.custom("Playpen", size: 20))
                            .foregroundColor(.white)

                        HStack(spacing: 10) {
                            glassyButton("ادبيات")   { go("ادبيات") }
                            glassyButton("فنونيات")  { go("فنونيات") }
                        }
                        HStack(spacing: 10) {
                            glassyButton("مطبخيات") { go("مطبخيات") }
                            glassyButton("مغامرات") { go("مغامرات") }
                        }
                        glassyButton("عشوائيات", width: 310) { go("عشوائيات") }
                    }
                }
                .padding()

                // Overlay تبع اختيار الشخصية (اختياري)
                if showCharacterPicker {
                    ZStack {
                        Color.black.opacity(0.6)
                            .ignoresSafeArea()
                            .onTapGesture { closeOverlayWithBounce() }

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
                                                                   ? [Color.white.opacity(0.5), primaryColor.opacity(0)]
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
                                    .init(color: secondaryColor.opacity(0.8), location: 1.5),
                                    .init(color: primaryColor, location: 1.0)
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
            // وجهة التنقل: نمرر اسم الفئة كـ String
            .navigationDestination(for: String.self) { category in
                CardView(category: category)
            }
        }
    }

    // MARK: - Actions
    private func go(_ category: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedButton = category
        }
        path.append(category) // يفتح CardView(category: ...)
    }

    // زر زجاجي يقبل أكشن
    private func glassyButton(_ title: String, width: CGFloat = 150, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Playpen_Bold", size: 20))
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
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.3), lineWidth: 3))
        }
    }

    // Overlay dismiss
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

// نقطة الدخول لو حابة
#Preview { homeView() }
