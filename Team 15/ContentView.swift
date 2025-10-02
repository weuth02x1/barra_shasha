import SwiftUI

// Extension لدعم Hex
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

struct ContentView: View {
    // متغيّرات الحركة
    @State private var animate = false       // لحركة صورة النص
    @State private var moveBG = false        // لحركة الخلفية

    var body: some View {
        ZStack {
            // الخلفية باللون اللي حاطّته
            Color(hex: "#81CCBB")
                .ignoresSafeArea()

            // الصورة الشفافة اللي فيها "برا الشاشة" بالخلفية
            Image("backgroundLogo")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                // ↓↓↓ الحركة الخفيفة للخلفية ↓↓↓
                .offset(x: moveBG ? 60 : -70, y: moveBG ? -50 : 50)
                .animation(.linear(duration: 11).repeatForever(autoreverses: true), value: moveBG)

            // صورة النص تتحرك بدل Text
            Image("textLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 280)
                .shadow(color: .black, radius: 3, x: 2, y: 2)
                // حركات كيوت
                .offset(y: animate ? -12 : 12)
                .rotationEffect(.degrees(animate ? 4 : -4))
                .scaleEffect(animate ? 1.05 : 0.95)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                .accessibilityLabel("برا الشاشة؟")
        }
        .environment(\.layoutDirection, .rightToLeft)
        .onAppear {
            animate = true
            moveBG = true
        }
    }
}

#Preview { ContentView() }
