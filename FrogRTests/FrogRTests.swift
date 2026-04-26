import XCTest
@testable import FrogR

final class FrogRTests: XCTestCase {

    func testGridConstants_areConsistent() {
        XCTAssertEqual(GridConstants.rows, 13)
        XCTAssertEqual(GridConstants.columns, 12)
        XCTAssertEqual(GridConstants.startRow, 12)
        XCTAssertEqual(GridConstants.goalRow, 0)
        XCTAssertTrue(GridConstants.waterRowRange.contains(3))
        XCTAssertTrue(GridConstants.roadRowRange.contains(9))
        XCTAssertEqual(GridConstants.safeRow, 6)
    }

    func testFrog_effectiveCol() {
        var frog = Frog(col: 5, row: 10, lives: 3, ridingOffset: 0.25)
        XCTAssertEqual(frog.effectiveCol, 5.25, accuracy: 0.001)

        frog.ridingOffset = -1.5
        XCTAssertEqual(frog.effectiveCol, 3.5, accuracy: 0.001)
    }

    func testLaneInit_defaultsEmpty() {
        let lane = Lane(type: .road, row: 7)
        XCTAssertTrue(lane.obstacles.isEmpty)
        XCTAssertTrue(lane.platforms.isEmpty)
    }
}
