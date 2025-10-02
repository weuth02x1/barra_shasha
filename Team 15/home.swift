import SwiftUI

struct homeView: View {
    // MARK: - State Properties
    @State private var selectedCharacter = "character1"   // Currently displayed character
    @State private var showCharacterPicker = false        // Controls whether the character picker overlay is visible
    @State private var tappedCharacter: Int? = nil        // Index of the character currently being tapped
    @State private var overlayBounce = false              // Triggers the bounce animation for the overlay
    @State private var selectedButton: String? = nil      // Keeps track of the selected interest button
    
    // MARK: - Custom Colors
    private let primaryColor = Color(red: 129/255, green: 204/255, blue: 187/255)   // Teal green background color
    private let secondaryColor = Color(red: 146/255, green: 227/255, blue: 213/255) // Lighter teal accent
    
    var body: some View {
        ZStack {
            // MARK: - Background
            primaryColor.ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // MARK: - Character Selection
                VStack(spacing: 12) {
                    Text("اختر شخصيتك:") // "Choose your character"
                        .font(.custom("Playpen_Bold", size: 20))
                        .foregroundColor(.white)
                    
                    Image(selectedCharacter)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .onTapGesture {
                            // Show overlay with bounce animation
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                showCharacterPicker = true
                                overlayBounce = true
                            }
                            // Reset bounce after delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                overlayBounce = false
                            }
                        }
                }
                
                // MARK: - Interest Selection
                VStack(spacing: 10) {
                    Text("اختر اهتمامك:") // "Choose your interest"
                        .font(.custom("Playpen", size: 20))
                        .foregroundColor(.white)
                    
                    // First row of buttons
                    HStack(spacing: 10) {
                        glassyButton("ادبيات")    // Literature
                        glassyButton("فنونيات")   // Arts
                    }
                    
                    // Second row of buttons
                    HStack(spacing: 10) {
                        glassyButton("مطبخيات")   // Cooking
                        glassyButton("مغامرات")   // Adventures
                    }
                    
                    // Third row (single wide button)
                    HStack(spacing: 10) {
                        glassyButton("عشوائيات", width: 310)  // Random
                    }
                }
            }
            .padding()
            
            // MARK: - Character Picker Overlay
            if showCharacterPicker {
                ZStack {
                    // Dark background (dismiss on tap)
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            closeOverlayWithBounce()
                        }
                    
                    // Character choices
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
                                    .scaleEffect(tappedCharacter == index ? 1.1 : 1.0) // Tap bounce
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: tappedCharacter)
                                    .onTapGesture {
                                        // Animate character tap and update selection
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 1.5)
                    )
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.bottom, 200)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: overlayBounce)
                }
            }
        }
    }
    
    // MARK: - Glassy Button Component
    private func glassyButton(_ title: String, width: CGFloat = 150) -> some View {
        Button {
            // Select button with bounce animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedButton = title
            }
        } label: {
            Text(title)
                .font(.custom("Playpen_Bold", size: 20))
                .foregroundColor(.white)
                .frame(width: width, height: 50)
                .background(
                    Group {
                        if selectedButton == title {
                            // Selected state gradient
                            AnyView(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0.15)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        } else {
                            // Default state gradient
                            AnyView(
                                RadialGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0)]),
                                    center: .topLeading,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                        }
                    }
                )
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .scaleEffect(selectedButton == title ? 1.07 : 1.0) // Bounce effect
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedButton)
        }
    }

    // MARK: - Overlay Dismissal with Bounce
    private func closeOverlayWithBounce() {
        // Animate bounce before closing
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            overlayBounce = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            overlayBounce = false
            // Smoothly hide overlay
            withAnimation(.spring(response: 0.5, dampingFraction: 0.9)) {
                showCharacterPicker = false
            }
        }
    }
}

#Preview {
    homeView()
}
