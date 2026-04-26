import SwiftUI

struct GameOverView: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Title
                Text("💀")
                    .font(.system(size: 64))

                Text("Game Over")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(.red)

                // Score
                VStack(spacing: 8) {
                    Text("Score")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.7))

                    Text("\(viewModel.score)")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    if viewModel.score >= viewModel.highScore && viewModel.score > 0 {
                        Text("🏆 New High Score!")
                            .font(.title3.bold())
                            .foregroundStyle(.yellow)
                    }
                }

                VStack(spacing: 6) {
                    Text("Level Reached: \(viewModel.level)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                // Buttons
                VStack(spacing: 14) {
                    Button {
                        viewModel.restartGame()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Play Again")
                        }
                        .font(.title3.bold())
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(.green, in: .capsule)
                        .foregroundStyle(.white)
                    }

                    Button {
                        viewModel.returnToMenu()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "house.fill")
                            Text("Main Menu")
                        }
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(.gray.opacity(0.5), in: .capsule)
                        .foregroundStyle(.white)
                    }
                }

                Spacer()
            }
            .padding()
        }
    }
}
