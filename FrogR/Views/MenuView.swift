import SwiftUI

struct MenuView: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.3, blue: 0.1),
                    Color(red: 0.0, green: 0.15, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Title
                VStack(spacing: 8) {
                    Text("🐸")
                        .font(.system(size: 80))
                        .shadow(color: .green.opacity(0.5), radius: 20)

                    Text("FrogR")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                    Text("Cross the road. Ride the logs. Don't croak!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // Start button
                Button {
                    viewModel.startGame()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                        Text("Start Game")
                    }
                    .font(.title2.bold())
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    .background(.green, in: .capsule)
                    .foregroundStyle(.white)
                    .shadow(color: .green.opacity(0.4), radius: 10, y: 4)
                }

                // High score
                if viewModel.highScore > 0 {
                    VStack(spacing: 4) {
                        Text("🏆 High Score")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))

                        Text("\(viewModel.highScore)")
                            .font(.system(size: 28, weight: .bold, design: .monospaced))
                            .foregroundStyle(.yellow)
                    }
                }

                Spacer()

                // Footer
                Text("Swipe to move • Avoid cars • Ride logs")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 20)
            }
            .padding()
        }
    }
}
