//
//  PomodoroTimerTests.swift
//  pomodoroTests
//
//  Created by Augusto Avelino on 29/02/24.
//

import XCTest
@testable import pomodoro

class PomodoroTimerTests: XCTestCase {
    
    var sut: PomodoroTimer!
    var timerDelegate: PomodoroTimerTestDelegate!
    
    override func setUp() {
        super.setUp()
        sut = PomodoroTimer(settings: PomodoroConfiguration(focusDuration: 5, shortBreakDuration: 2, longBreakDuration: 3, focusLimit: 2))
        timerDelegate = PomodoroTimerTestDelegate()
        sut.delegate = timerDelegate
    }
    
    override func tearDown() {
        sut.stop()
        sut = nil
        timerDelegate = nil
        super.tearDown()
    }
    
    func test_setDuration_shouldChangeDurationOfFocusMode() {
        XCTAssertEqual(sut.duration(for: .focus), 5)
        sut.setDuration(10, for: .focus)
        XCTAssertEqual(sut.duration(for: .focus), 10)
    }
    
    func test_setDuration_shouldChangeDurationOfShortBreakMode() {
        XCTAssertEqual(sut.duration(for: .shortBreak), 2)
        sut.setDuration(4, for: .shortBreak)
        XCTAssertEqual(sut.duration(for: .shortBreak), 4)
    }
    
    func test_setDuration_shouldChangeDurationOfLongBreakMode() {
        XCTAssertEqual(sut.duration(for: .longBreak), 3)
        sut.setDuration(6, for: .longBreak)
        XCTAssertEqual(sut.duration(for: .longBreak), 6)
    }
    
    func test_init_shouldInitiateInStoppedState() {
        XCTAssertEqual(sut.currentState, .stopped)
    }

    func test_start_shouldChangeStateToRunning() {
        sut.start()
        XCTAssertEqual(sut.currentState, .running)
    }

    func test_pause_shouldChangeStateToPaused() {
        sut.start()
        sut.pause()
        XCTAssertEqual(sut.currentState, .paused)
    }

    func test_stop_shouldChangeStateToStopped() {
        sut.start()
        sut.stop()
        XCTAssertEqual(sut.currentState, .stopped)
    }

    func test_stop_shouldClearElapsedTime() {
        let expectation = expectation(description: "Wait for elapsed time update")
        timerDelegate.didUpdateElapsedTime = { currentElapsedTime in
            if currentElapsedTime == 1.0 { expectation.fulfill() }
        }
        
        sut.start()
        wait(for: [expectation], timeout: 1.0)
        sut.stop()
        
        XCTAssertEqual(sut.elapsedTime, 0.0)
    }
    
    func test_start_shouldSetModeToShortBreak_whenFirstFocusSessionEnds() {
        let focusExpectation = expectation(description: "Wait for the end of focus session")
        timerDelegate.didChangeMode = { transition in
            if transition == (.focus, .shortBreak) {
                focusExpectation.fulfill()
            }
        }
        
        sut.start()
        wait(for: [focusExpectation], timeout: 5.0)
        
        XCTAssertEqual(sut.currentMode, .shortBreak)
    }
    
    func test_start_shouldSetModeToFocus_whenShortBreakSessionEnds() {
        let focusExpectation = expectation(description: "Wait for the end of focus session")
        let shortBreakExpectation = expectation(description: "Wait for the end of short break session")
        timerDelegate.didChangeMode = { transition in
            if transition == (.focus, .shortBreak) {
                focusExpectation.fulfill()
            } else if transition.from == .shortBreak {
                shortBreakExpectation.fulfill()
            }
        }
        
        sut.start()
        wait(for: [focusExpectation, shortBreakExpectation], timeout: 7.0)
        
        XCTAssertEqual(sut.currentMode, .focus)
    }
    
    func test_start_shouldSetModeToLongBreak_whenTheLastFocusSessionEnds() {
        let focusExpectation = expectation(description: "Wait for the end of focus session")
        focusExpectation.expectedFulfillmentCount = sut.configuration.focusLimit
        timerDelegate.didChangeMode = { transition in
            if transition.from == .focus {
                focusExpectation.fulfill()
            }
        }
        
        sut.start()
        wait(for: [focusExpectation], timeout: 19.0)
        
        XCTAssertEqual(sut.currentMode, .longBreak)
    }
    
    func test_start_shouldRunThroughAllSessions() {
        let focusLimit = sut.configuration.focusLimit
        let focusExpectation = expectation(description: "Wait for the end of focus session")
        focusExpectation.expectedFulfillmentCount = focusLimit
        let shortBreakExpectation = expectation(description: "Wait for the end of short break session")
        shortBreakExpectation.expectedFulfillmentCount = focusLimit - 1
        let longBreakExpectation = expectation(description: "Wait for the end of long break session")
        let finalExpectation = expectation(description: "Wait for the end of the pomodoro session")
        timerDelegate.willChangeMode = { transition in
            switch transition.from {
            case .focus: focusExpectation.fulfill()
            case .shortBreak: shortBreakExpectation.fulfill()
            case .longBreak: longBreakExpectation.fulfill()
            }
        }
        timerDelegate.didChangeMode = { transition in
            if transition.from == .longBreak {
                finalExpectation.fulfill()
            }
        }
        
        sut.start()
        wait(for: [focusExpectation, shortBreakExpectation, longBreakExpectation, finalExpectation], timeout: 22.0)
        
        XCTAssertEqual(sut.currentMode, .focus)
        XCTAssertEqual(sut.elapsedTime, 0)
    }
}

// MARK: - Helper PomodoroTimerDelegate

class PomodoroTimerTestDelegate: PomodoroTimerDelegate {
    typealias ModeTransition = (from: PomodoroTimer.Mode, to: PomodoroTimer.Mode)
    
    var didUpdateElapsedTime: ((TimeInterval) -> Void)?
    var didChangeMode: ((ModeTransition) -> Void)?
    var willChangeMode: ((ModeTransition) -> Void)?
    
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval) {
        didUpdateElapsedTime?(elapsedTime)
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, willChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode) {
        willChangeMode?((currentMode, newMode))
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeFrom previousMode: PomodoroTimer.Mode, to currentMode: PomodoroTimer.Mode) {
        didChangeMode?((previousMode, currentMode))
    }
}
