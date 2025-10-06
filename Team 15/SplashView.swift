import SwiftUI

struct SplashView: View {
    @State private var animate = false
    @State private var moveBG = false
    @State private var navigateToHome = false   // ← جديد: فلاغ الانتقال

    var body: some View {
        NavigationStack {
            ZStack {
                // نفس لونك #81CCBB بدون استخدام امتداد
                Color(red: 129/255, green: 204/255, blue: 187/255)
                    .ignoresSafeArea()

                // نفس حركة الخلفية تمامًا
                Image("backgroundLogo")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .offset(x: moveBG ? 60 : -70, y: moveBG ? -50 : 50)
                    .animation(.linear(duration: 11)
                                .repeatForever(autoreverses: true),
                               value: moveBG)

                // نفس حركة اللوقو النصي تمامًا
                Image("textLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280)
                    .shadow(color: .black, radius: 3, x: 2, y: 2)
                    .offset(y: animate ? -12 : 12)
                    .rotationEffect(.degrees(animate ? 4 : -4))
                    .scaleEffect(animate ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true),
                               value: animate)
            }
            // ← الضغط بأي مكان يودّي للهوم
            .contentShape(Rectangle())
            .onTapGesture { navigateToHome = true }

            // تفعيل الأنيميشنات
            .onAppear {
                animate = true
                moveBG = true
            }

            // ← الانتقال لصفحة الهوم (اختيار الشخصية)
            .navigationDestination(isPresented: $navigateToHome) {
                HomeView()    // إذا اسمك HomeView غيّريها إلى HomeView()
            }
        }
    }
}
