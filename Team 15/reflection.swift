//
//  reflection.swift
//  Team 15
//
//  Created by aljawharah alowayridhi on 10/04/1447 AH.
//
//  jojoView.swift
//  Created by aljawharah alowayridhi on 07/04/1447 AH.
// ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡
import SwiftUI
// Extension لدعم Hex 🥝 🍭 ↓
// extension Color {
   // init(hex: String) {
       // let scanner = Scanner(string: hex)
       // _ = scanner.scanString("#")
       // var rgb: UInt64 = 0
      //  scanner.scanHexInt64(&rgb)
      //  let r = Double((rgb >> 16) & 0xFF) / 255.0
       // let g = Double((rgb >> 8) & 0xFF) / 255.0
      //  let b = Double(rgb & 0xFF) / 255.0
       // self.init(red: r, green: g, blue: b)
   // }



// ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡
struct reflectionView: View { // ~ لأن الملف اسمه jojoView ☆ 📁 ♡ ~
    @State private var moveRight = false // state for title movement 🌧️
    @State private var pulseFeelingText = false   // جديد: تأثير النص
    
    // ↓ state for select mode with emojis 🌱💧 ↓
    @State private var selected1 = false
    @State private var selected2 = false
    @State private var selected3 = false
    var body: some View {
        ZStack {
            Color(hex: "#81CCBB") // لون الخلفيه 🍦⭐️
                .ignoresSafeArea()
            
//               ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦

            Image("الخلفيه")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
// ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡
            VStack(spacing: 40) {
                Image("وش شعورك")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 80)
                    .shadow(radius: 2)
                    .offset(x: moveRight ? 20 : -20)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true),
                               value: moveRight)
                    .onAppear {
                        moveRight.toggle() // اضيف انميشن لسؤال ✧✨⭒
                    }

                // 💕👇 هنا النص مع تأثير in-out ↓
                    .font(.system(size: 22, weight: .semibold))
                    
                    .opacity(pulseFeelingText ? 3.0 : 0.55)
                // ★✮الشفافيه★✮
                
                    .scaleEffect(pulseFeelingText ? 1.05 : 0.95)
                // ☆ يكبر ويصغر ☆
                
                    .animation(.easeInOut(duration: 2)
                                .repeatForever(autoreverses: true),
                               value: pulseFeelingText)
                    .onAppear { pulseFeelingText = true }
// ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡
                HStack(spacing: 50) {
                            HStack(spacing: 50) {
                                emojiButton(index: 0, emoji: "😊", title: "افضل", isSelected: $selected1)
                                    .shadow(radius: 2)
                                emojiButton(index: 1, emoji: "😐", title: "عادي", isSelected: $selected2)
                                    .shadow(radius: 2)
                                emojiButton(index: 2, emoji: "😔", title: "اسوأ", isSelected: $selected3)
                                    .shadow(radius: 2)
                            }
                        }
                    }

                }
            }
        }

// زر الايموجي ↓ 🌈 🐱
struct emojiButton: View {
    let index: Int
    let emoji: String
    let title: String
    @Binding var isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 40))
                .opacity(isSelected ? 1.0 : 0.5) // مثال على تغيير الشكل
                .onTapGesture {
                    isSelected.toggle() // هنا يصير التبديل
                }
            Image(title)
                .font(.caption)
        }
    }
}
// ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡ ♡
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        reflectionView()
    }
}

