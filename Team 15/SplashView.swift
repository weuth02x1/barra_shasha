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
struct SplashView: View {
    @State private var animate = false
    @State private var moveBG = false
    @State private var navigateToHome = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "#81CCBB")
                    .ignoresSafeArea()

                Image("backgroundLogo")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .offset(x: moveBG ? 60 : -70, y: moveBG ? -50 : 50)
                    .animation(.linear(duration: 11).repeatForever(autoreverses: true), value: moveBG)

                Image("textLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)
                    .shadow(color: .black, radius: 3, x: 2, y: 2)
                    .offset(y: animate ? -12 : 12)
                    .rotationEffect(.degrees(animate ? 4 : -4))
                    .scaleEffect(animate ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                    .accessibilityLabel("برا الشاشة؟")

                NavigationLink(destination: homeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .onAppear {
                animate = true
                moveBG = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    navigateToHome = true
                }
            }
            .navigationBarHidden(true)
        }
    }
}
#Preview {
    SplashView()
}

