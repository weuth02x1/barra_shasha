import SwiftUI

// MARK: - Color helper
@inline(__always)
func colorHex(_ hex: String) -> Color {
    var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if s.hasPrefix("#") { s.removeFirst() }
    var rgb: UInt64 = 0
    Scanner(string: s).scanHexInt64(&rgb)
    let r = Double((rgb >> 16) & 0xFF) / 255.0
    let g = Double((rgb >> 8) & 0xFF) / 255.0
    let b = Double(rgb & 0xFF) / 255.0
    return Color(red: r, green: g, blue: b)
}

// MARK: - Reflection View
struct reflectionView: View {
    @State private var moveRight = false
    @State private var pulseFeeling = false

    // اختصار: مؤشر عنصر مختار بدل 3 بوليانات
    @State private var selectedIndex: Int? = nil

    var body: some View {
        ZStack {
            // خلفية اللون
            colorHex("#81CCBB").ignoresSafeArea()

            // خلفية صورة شفافة (لو ما كانت موجودة ما ينهار التطبيق؛ بتكون بس شفافة)
            Image("الخلفيه")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .opacity(0.15)

            VStack(spacing: 40) {

                // عنوان "وش شعورك؟" كصورة مع أنيميشن هادي
                Image("وش شعورك")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 90)
                    .shadow(radius: 2)
                    .offset(x: moveRight ? 20 : -20)
                    .scaleEffect(pulseFeeling ? 1.05 : 0.95)
                    .opacity(pulseFeeling ? 1.0 : 0.65) // 0...1 فقط
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: moveRight)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: pulseFeeling)
                    .onAppear {
                        moveRight.toggle()
                        pulseFeeling = true
                    }

                // الأزرار: توزيع متساوي وبدون قصّ للنصوص
                HStack {
                    Spacer()
                    EmojiButton(index: 0, emoji: "😊", title: "أفضل",    selectedIndex: $selectedIndex)
                    Spacer()
                    EmojiButton(index: 1, emoji: "😐", title: "نفس الشي", selectedIndex: $selectedIndex)
                    Spacer()
                    EmojiButton(index: 2, emoji: "😔", title: "أسوأ",    selectedIndex: $selectedIndex)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 16)
            }
            .padding(.top, 20)
        }
    }
}

// MARK: - Emoji Button component
struct EmojiButton: View {
    let index: Int
    let emoji: String
    let title: String
    @Binding var selectedIndex: Int?

    var isSelected: Bool { selectedIndex == index }

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 42))
                .opacity(isSelected ? 1.0 : 0.8)

            // مهم: Text وليس Image(title)
            Text(title)
                .font(.callout.weight(.semibold))
                .foregroundStyle(.white.opacity(0.95))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity)
        }
        .frame(width: 90)                      // مساحة كافية لظهور العنوان
        .contentShape(Rectangle())             // منطقة لمس أوسع
        .onTapGesture { selectedIndex = index }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? .white.opacity(0.35) : .clear, lineWidth: 1)
        )
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        reflectionView()
            .previewDevice("iPhone 16 Pro")
    }
}
