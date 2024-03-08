//
//  PomodoroTimerTests.swift
//  pomodoroTests
//
//  Created by Augusto Avelino on 29/02/24.
//

import XCTest
@testable import pomodoro

class PomodoroTimerTests: XCTestCase {

    var timer: PomodoroTimer!
    var timerDelegate: PomodoroTimerTestDelegate!

    override func setUp() {
        super.setUp()
        timer = PomodoroTimer(settings: PomodoroConfiguration(focusDuration: 5, shortBreakDuration: 2, longBreakDuration: 3, focusLimit: 2))
        timerDelegate = PomodoroTimerTestDelegate()
        timer.delegate = timerDelegate
    }

    override func tearDown() {
        timer = nil
        timerDelegate = nil
        super.tearDown()
    }
    
    func testTimerSetsDurationsCorrectly() {
        XCTAssertEqual(timer.duration(for: .focus), 5)
        XCTAssertEqual(timer.duration(for: .shortBreak), 2)
        XCTAssertEqual(timer.duration(for: .longBreak), 3)
        
        timer.setDuration(10, for: .focus)
        timer.setDuration(4, for: .shortBreak)
        timer.setDuration(6, for: .longBreak)
        
        XCTAssertEqual(timer.duration(for: .focus), 10)
        XCTAssertEqual(timer.duration(for: .shortBreak), 4)
        XCTAssertEqual(timer.duration(for: .longBreak), 6)
    }

    func testTimerStartsSuccessfully() {
        XCTAssertEqual(timer.currentState, .stopped)
        timer.start()
        XCTAssertEqual(timer.currentState, .running)
    }

    func testTimerPausesSuccessfully() {
        timer.start()
        XCTAssertEqual(timer.currentState, .running)
        timer.pause()
        XCTAssertEqual(timer.currentState, .paused)
    }

    func testTimerStopsSuccessfully() {
        timer.start()
        XCTAssertEqual(timer.currentState, .running)
        timer.stop()
        XCTAssertEqual(timer.currentState, .stopped)
        XCTAssertEqual(timer.elapsedTime, 0)
    }
    
    func testModeTransitionsFromFocusToShortBreak() {
        let focusExpectation = expectation(description: "Wait 5 seconds for focus mode to end")
        timerDelegate.didBeginShortBreak = { focusExpectation.fulfill() }
        
        timer.start()
        
        XCTAssertEqual(timer.currentMode, .focus)
        XCTAssertEqual(timer.elapsedTime, 0)
        
        wait(for: [focusExpectation])
        
        XCTAssertEqual(timer.currentMode, .shortBreak)
        XCTAssertEqual(timer.elapsedTime, 0)
    }
    
    func testModeTransitionsFromShortBreakToFocus() {
        let focusExpectation = expectation(description: "Wait 5 seconds for focus mode to end")
        let shortBreakExpectation = expectation(description: "Wait 2 seconds for short break mode to end")
        timerDelegate.didBeginShortBreak = { focusExpectation.fulfill() }
        timerDelegate.didBeginFocus = { shortBreakExpectation.fulfill() }
        
        timer.start()
        
        wait(for: [focusExpectation, shortBreakExpectation])
        
        XCTAssertEqual(timer.currentMode, .focus)
        XCTAssertEqual(timer.elapsedTime, 0)
    }
    
    func testModeTransitionsFromFocusToLongBreak() {
        var focusCount = 0
        let focusExpectation1 = expectation(description: "Wait 5 seconds for focus mode to end before short break")
        let focusExpectation2 = expectation(description: "Wait 5 seconds for focus mode to end after short break")
        let shortBreakExpectation = expectation(description: "Wait 2 seconds for short break mode to end")
        timerDelegate.didBeginFocus = { shortBreakExpectation.fulfill() }
        timerDelegate.didBeginShortBreak = {
            if focusCount == 0 { focusExpectation1.fulfill() }
            else { focusExpectation2.fulfill() }
            focusCount += 1
        }
        
        timer.start()
        
        wait(for: [focusExpectation1, shortBreakExpectation, focusExpectation2], enforceOrder: true)
        
        XCTAssertEqual(timer.currentMode, .longBreak)
        XCTAssertEqual(timer.elapsedTime, 0)
    }
}

class PomodoroTimerTestDelegate: PomodoroTimerDelegate {
    var didUpdateElapsedTime: ((TimeInterval) -> Void)?
    var didBeginFocus: (() -> Void)?
    var didBeginShortBreak: (() -> Void)?
    var didBeginLongBreak: (() -> Void)?
    
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval) {
        didUpdateElapsedTime?(elapsedTime)
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeTo currentMode: PomodoroTimer.Mode) {
        switch currentMode {
        case .focus:
            didBeginFocus?()
        case .shortBreak:
            didBeginShortBreak?()
        case .longBreak:
            didBeginShortBreak?()
        }
    }
}
