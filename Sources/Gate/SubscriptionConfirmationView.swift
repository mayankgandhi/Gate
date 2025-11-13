import SwiftUI

/// A celebration view shown after successful subscription purchase
public struct SubscriptionConfirmationView: View {
    let title: String
    let message: String?
    let onDismiss: () -> Void

    @State private var showCheckmark = false
    @State private var showConfetti = false
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    public init(
        title: String,
        message: String? = nil,
        onDismiss: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            // Background blur
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            // Main content card
            VStack(spacing: 24) {
                // Success icon with animation
                ZStack {
                    // Checkmark background circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .scaleEffect(showCheckmark ? 1 : 0.5)
                        .opacity(showCheckmark ? 1 : 0)

                    // Checkmark icon
                    Image(systemName: "checkmark")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(showCheckmark ? 1 : 0.5)
                        .opacity(showCheckmark ? 1 : 0)
                }
                .overlay {
                    // Confetti particles
                    if showConfetti {
                        ConfettiView()
                    }
                }

                // Title
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .opacity(opacity)

                // Optional message
                if let message = message {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .opacity(opacity)
                }
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.regularMaterial)
            }
            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
            .scaleEffect(scale)
            .opacity(opacity)
            .padding(40)
        }
        .onAppear {
            // Trigger haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            // Animate entrance
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1
                opacity = 1
            }

            // Show checkmark after brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    showCheckmark = true
                }

                // Show confetti
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showConfetti = true

                    // Success haptic
                    let notification = UINotificationFeedbackGenerator()
                    notification.notificationOccurred(.success)
                }
            }

            // Auto-dismiss after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    opacity = 0
                    scale = 0.9
                }

                // Call dismiss after animation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onDismiss()
                }
            }
        }
    }
}

// MARK: - Confetti Animation

private struct ConfettiView: View {
    @State private var confettiParticles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiParticles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .offset(
                            x: particle.x,
                            y: particle.y
                        )
                        .opacity(particle.opacity)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
        }
        .onAppear {
            generateConfetti()
        }
    }

    private func generateConfetti() {
        let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

        for _ in 0..<30 {
            let particle = ConfettiParticle(
                color: colors.randomElement()!,
                x: CGFloat.random(in: -100...100),
                y: 0,
                size: CGFloat.random(in: 4...8)
            )
            confettiParticles.append(particle)

            // Animate particle
            withAnimation(
                .easeOut(duration: Double.random(in: 1.0...1.5))
                .delay(Double.random(in: 0...0.3))
            ) {
                if let index = confettiParticles.firstIndex(where: { $0.id == particle.id }) {
                    confettiParticles[index].y = CGFloat.random(in: 150...250)
                    confettiParticles[index].x += CGFloat.random(in: -50...50)
                    confettiParticles[index].opacity = 0
                    confettiParticles[index].rotation = Double.random(in: -360...360)
                }
            }
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let color: Color
    var x: CGFloat
    var y: CGFloat
    let size: CGFloat
    var opacity: Double = 1
    var rotation: Double = 0
}

// MARK: - Preview

#Preview {
    SubscriptionConfirmationView(
        title: "Welcome to Ticker Pro!",
        message: nil,
        onDismiss: {}
    )
}
