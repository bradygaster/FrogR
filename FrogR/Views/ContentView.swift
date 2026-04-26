import SwiftUI

struct ContentView: View {
    @State private var viewModel = GameViewModel()

    var body: some View {
        Group {
            switch viewModel.gameState {
            case .menu:
                MenuView(viewModel: viewModel)
            case .playing, .paused:
                GameView(viewModel: viewModel)
            case .gameOver:
                GameOverView(viewModel: viewModel)
            case .won:
                GameOverView(viewModel: viewModel) // reuse with win state later
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.gameState)
    }
}
