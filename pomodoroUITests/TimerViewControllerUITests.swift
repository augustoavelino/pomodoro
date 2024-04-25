//
//  TimerViewControllerUITests.swift
//  pomodoroUITests
//
//  Created by Augusto Avelino on 25/04/24.
//

import XCTest

final class TimerViewControllerUITests: XCTestCase {

    override func setUpWithError() throws {
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.otherElements["timerViewController.timerDisplay"].exists)
        
        let minutesLabel = app.staticTexts.element(matching: .any, identifier: "timerDisplay.minutesLabel")
        XCTAssertTrue(minutesLabel.exists)
        let blinkingLabel = app.staticTexts.element(matching: .any, identifier: "timerDisplay.blinkingLabel")
        XCTAssertTrue(blinkingLabel.exists)
        let secondsLabel = app.staticTexts.element(matching: .any, identifier: "timerDisplay.secondsLabel")
        XCTAssertTrue(secondsLabel.exists)
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
