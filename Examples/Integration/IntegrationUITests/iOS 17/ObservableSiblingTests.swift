import InlineSnapshotTesting
import TestCases
import XCTest

@MainActor
final class ObservableSiblingsTests: BaseIntegrationTests {
  override func setUp() {
    super.setUp()
    self.app.buttons["Observable Siblings"].tap()
    self.clearLogs()
    // SnapshotTesting.isRecording = true
  }

  func testBasics() {
    self.app.buttons["Increment"].firstMatch.tap()
    XCTAssertEqual(self.app.staticTexts["1"].exists, true)
    self.assertLogs {
      """
      ObservableBasicsView.body
      StoreOf<ObservableSiblingFeaturesView.Feature>.scope
      """
    }
  }

  func testResetAll() {
    self.app.buttons["Increment"].firstMatch.tap()
    XCTAssertEqual(self.app.staticTexts["1"].exists, true)
    self.clearLogs()
    self.app.buttons["Reset all"].tap()
    XCTAssertEqual(self.app.staticTexts["1"].exists, false)
    self.assertLogs {
      """
      StoreOf<ObservableSiblingFeaturesView.Feature>.scope
      StoreOf<ObservableSiblingFeaturesView.Feature>.scope
      """
    }
  }

  func testResetSelf() {
    self.app.buttons["Increment"].firstMatch.tap()
    XCTAssertEqual(self.app.staticTexts["1"].exists, true)
    self.clearLogs()
    self.app.buttons["Reset self"].tap()
    XCTAssertEqual(self.app.staticTexts["1"].exists, false)
    self.assertLogs {
      """
      StoreOf<ObservableSiblingFeaturesView.Feature>.scope
      StoreOf<ObservableSiblingFeaturesView.Feature>.scope
      """
    }
  }

  func testResetSwap() {
    self.app.buttons["Increment"].firstMatch.tap()
    XCTAssertEqual(self.app.staticTexts["1"].exists, true)
    self.clearLogs()
    self.app.buttons["Swap"].tap()
    XCTAssertEqual(self.app.staticTexts["1"].exists, true)
    self.assertLogs {
      """
      StoreOf<ObservableSiblingFeaturesView.Feature>.scope
      StoreOf<ObservableSiblingFeaturesView.Feature>.scope
      """
    }
  }
}
