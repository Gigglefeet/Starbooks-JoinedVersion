import SwiftUI

struct AchievementNotificationView: View {
    let achievement: ReadingAchievement
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Achievement icon with celebration effect
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.yellow)
            }
            .scaleEffect(isPresented ? 1.2 : 1.0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isPresented)
            
            VStack(spacing: 8) {
                Text("Achievement Unlocked! 🎉")
                    .font(.headline)
                    .foregroundColor(.yellow)
                
                Text(achievement.rawValue)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Continue Reading! 🚀") {
                isPresented = false
            }
            .foregroundColor(.blue)
            .padding(.top)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.yellow.opacity(0.3), lineWidth: 2)
                )
        )
        .padding(.horizontal, 32)
        .transition(.scale.combined(with: .opacity))
    }
}

struct AchievementToastView: View {
    let achievement: ReadingAchievement
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            HStack(spacing: 12) {
                Image(systemName: achievement.icon)
                    .foregroundColor(.yellow)
                    .font(.title3)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Achievement!")
                        .font(.caption)
                        .foregroundColor(.yellow)
                    Text(achievement.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button {
                    withAnimation {
                        isShowing = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                    )
            )
            .padding(.horizontal)
            .transition(.move(edge: .top).combined(with: .opacity))
            .onAppear {
                // Auto-dismiss after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
    }
}

#Preview {
    struct AchievementPreviewWrapper: View {
        @State private var showingModal = true
        @State private var showingToast = true
        
        var body: some View {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Button("Show Modal") {
                        showingModal = true
                    }
                    
                    Button("Show Toast") {
                        showingToast = true
                    }
                }
            }
            .overlay(alignment: .top) {
                AchievementToastView(
                    achievement: .streak7,
                    isShowing: $showingToast
                )
                .padding(.top, 50)
            }
            .overlay {
                if showingModal {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showingModal = false
                        }
                    
                    AchievementNotificationView(
                        achievement: .firstBook,
                        isPresented: $showingModal
                    )
                }
            }
        }
    }
    
    return AchievementPreviewWrapper()
} 