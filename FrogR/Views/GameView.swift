import SwiftUI

struct GameView: View {
    @Bindable var viewModel: GameViewModel

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: viewModel.gameState != .playing)) { timeline in
            let _ = viewModel.tick(date: timeline.date)

            GeometryReader { geo in
                let cellWidth = geo.size.width / CGFloat(GridConstants.columns)
                let cellHeight = geo.size.height / CGFloat(GridConstants.rows)

                ZStack(alignment: .topLeading) {
                    // Lane backgrounds
                    ForEach(viewModel.lanes) { lane in
                        laneBackground(lane: lane, cellWidth: cellWidth, cellHeight: cellHeight, totalWidth: geo.size.width)
                    }

                    // Goal slots
                    goalSlots(cellWidth: cellWidth, cellHeight: cellHeight)

                    // Platforms
                    ForEach(viewModel.lanes) { lane in
                        ForEach(lane.platforms) { platform in
                            platformView(platform: platform, row: lane.row, cellWidth: cellWidth, cellHeight: cellHeight)
                        }
                    }

                    // Obstacles
                    ForEach(viewModel.lanes) { lane in
                        ForEach(lane.obstacles) { obstacle in
                            obstacleView(obstacle: obstacle, row: lane.row, cellWidth: cellWidth, cellHeight: cellHeight)
                        }
                    }

                    // Frog
                    frogView(cellWidth: cellWidth, cellHeight: cellHeight)

                    // HUD
                    hudOverlay(totalWidth: geo.size.width)

                    // Pause overlay
                    if viewModel.gameState == .paused {
                        pauseOverlay()
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .clipped()
            }
            .gesture(swipeGesture)
            .ignoresSafeArea()
        }
    }

    // MARK: - Lane Background

    @ViewBuilder
    private func laneBackground(lane: Lane, cellWidth: CGFloat, cellHeight: CGFloat, totalWidth: CGFloat) -> some View {
        Rectangle()
            .fill(laneColor(lane.type))
            .frame(width: totalWidth, height: cellHeight)
            .offset(y: CGFloat(lane.row) * cellHeight)
    }

    private func laneColor(_ type: LaneType) -> Color {
        switch type {
        case .road: return Color(red: 0.25, green: 0.25, blue: 0.28)
        case .water: return Color(red: 0.1, green: 0.3, blue: 0.7)
        case .safe: return Color(red: 0.2, green: 0.6, blue: 0.2)
        case .goal: return Color(red: 0.15, green: 0.5, blue: 0.15)
        }
    }

    // MARK: - Goal Slots

    @ViewBuilder
    private func goalSlots(cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        let slotCount = 4
        let slotWidth = CGFloat(GridConstants.columns) / CGFloat(slotCount)

        ForEach(0..<slotCount, id: \.self) { slot in
            let centerX = (CGFloat(slot) + 0.5) * slotWidth * cellWidth
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(viewModel.goalsReached.contains(slot) ? Color.green.opacity(0.8) : Color.black.opacity(0.3))
                    .frame(width: cellWidth * 1.5, height: cellHeight * 0.8)

                if viewModel.goalsReached.contains(slot) {
                    Text("🐸")
                        .font(.system(size: cellHeight * 0.5))
                }
            }
            .position(x: centerX, y: cellHeight * 0.5)
        }
    }

    // MARK: - Platform View

    @ViewBuilder
    private func platformView(platform: Platform, row: Int, cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        let repeatCount = max(Int(platform.width), 1)
        HStack(spacing: 0) {
            ForEach(0..<repeatCount, id: \.self) { _ in
                Text(platform.emoji)
                    .font(.system(size: cellHeight * 0.6))
                    .frame(width: cellWidth, height: cellHeight)
            }
        }
        .offset(
            x: CGFloat(platform.x) * cellWidth,
            y: CGFloat(row) * cellHeight
        )
    }

    // MARK: - Obstacle View

    @ViewBuilder
    private func obstacleView(obstacle: Obstacle, row: Int, cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        let repeatCount = max(Int(obstacle.width), 1)
        HStack(spacing: 0) {
            ForEach(0..<repeatCount, id: \.self) { _ in
                Text(obstacle.emoji)
                    .font(.system(size: cellHeight * 0.6))
                    .frame(width: cellWidth, height: cellHeight)
            }
        }
        .scaleEffect(x: obstacle.direction == .left ? -1 : 1, y: 1)
        .offset(
            x: CGFloat(obstacle.x) * cellWidth,
            y: CGFloat(row) * cellHeight
        )
    }

    // MARK: - Frog

    @ViewBuilder
    private func frogView(cellWidth: CGFloat, cellHeight: CGFloat) -> some View {
        Text("🐸")
            .font(.system(size: cellHeight * 0.7))
            .frame(width: cellWidth, height: cellHeight)
            .offset(
                x: CGFloat(viewModel.frog.effectiveCol) * cellWidth,
                y: CGFloat(viewModel.frog.row) * cellHeight
            )
            .animation(.easeOut(duration: 0.1), value: viewModel.frog.col)
            .animation(.easeOut(duration: 0.1), value: viewModel.frog.row)
    }

    // MARK: - HUD

    @ViewBuilder
    private func hudOverlay(totalWidth: CGFloat) -> some View {
        VStack {
            HStack {
                Text(viewModel.formattedScore)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)

                Spacer()

                Text(viewModel.livesDisplay)
                    .font(.system(size: 16))

                Spacer()

                Text(viewModel.currentLevelDisplay)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.white)
                    .shadow(radius: 2)

                Button {
                    viewModel.pauseGame()
                } label: {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white.opacity(0.9))
                        .shadow(radius: 2)
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal, 12)
            .padding(.top, 50)

            Spacer()
        }
    }

    // MARK: - Pause Overlay

    @ViewBuilder
    private func pauseOverlay() -> some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()

        VStack(spacing: 20) {
            Text("PAUSED")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Button {
                viewModel.resumeGame()
            } label: {
                Label("Resume", systemImage: "play.fill")
                    .font(.title2.bold())
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(.green, in: .capsule)
                    .foregroundStyle(.white)
            }

            Button {
                viewModel.returnToMenu()
            } label: {
                Label("Main Menu", systemImage: "house.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(.gray.opacity(0.7), in: .capsule)
                    .foregroundStyle(.white)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Swipe Gesture

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20, coordinateSpace: .local)
            .onEnded { value in
                let dx = value.translation.width
                let dy = value.translation.height

                if abs(dx) > abs(dy) {
                    viewModel.handleSwipe(dx > 0 ? .right : .left)
                } else {
                    viewModel.handleSwipe(dy > 0 ? .down : .up)
                }
            }
    }
}
