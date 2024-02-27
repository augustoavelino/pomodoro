//
//  PomodoroTimer.swift
//  pomodoro
//
//  Created by Augusto Avelino on 26/02/24.
//

import Foundation
import UserNotifications

protocol PomodoroTimerDelegate: AnyObject {
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval)
    func pomodoroTimer(_ timer: PomodoroTimer, willChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode)
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeTo currentMode: PomodoroTimer.Mode)
}

extension PomodoroTimerDelegate {
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval) {}
    func pomodoroTimer(_ timer: PomodoroTimer, willChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode) {}
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeTo currentMode: PomodoroTimer.Mode) {}
}

class PomodoroTimer {
    var focusDuration: TimeInterval
    var shortBreakDuration: TimeInterval
    var longBreakDuration: TimeInterval
    private(set) var elapsedTime: TimeInterval
    private(set) var currentState: State
    var currentMode: Mode
    weak var delegate: PomodoroTimerDelegate?
    private var timer: Timer?
    
    static var `default`: PomodoroTimer { PomodoroTimer(focusDuration: 1500.0, shortBreakDuration: 300.0, longBreakDuration: 900.0) }
    
    init(focusDuration: TimeInterval, shortBreakDuration: TimeInterval, longBreakDuration: TimeInterval) {
        self.focusDuration = focusDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.elapsedTime = 0
        self.currentState = .stopped
        self.currentMode = .focus
    }
    
    func start() {
        guard currentState != .running else { return }
        
        currentState = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timerDidFire()
        }
    }
    
    func pause() {
        guard currentState == .running else { return }
        
        currentState = .paused
        timer?.invalidate()
    }
    
    func stop() {
        guard currentState != .stopped else { return }
        
        currentState = .stopped
        timer?.invalidate()
        elapsedTime = 0
    }
    
    func currentTimeRemaining() -> TimeInterval {
        var currentDuration: TimeInterval
        switch currentMode {
        case .focus: currentDuration = focusDuration
        case .shortBreak: currentDuration = shortBreakDuration
        case .longBreak: currentDuration = longBreakDuration
        }
        return currentDuration - elapsedTime
    }
    
    private func timerDidFire() {
        if currentState == .running {
            elapsedTime += 1
            delegate?.pomodoroTimer(self, didUpdateElapsedTime: elapsedTime)
        }
        if currentTimeRemaining() <= 0 {
            modeCompleted()
        }
    }
    
    private func modeCompleted() {
        elapsedTime = 0
        let newMode: Mode
        switch currentMode {
        case .focus:
            newMode = .shortBreak
        case .shortBreak:
            newMode = .longBreak
        case .longBreak:
            newMode = .focus
        }
        delegate?.pomodoroTimer(self, willChangeModeFrom: currentMode, to: newMode)
        currentMode = newMode
        delegate?.pomodoroTimer(self, didChangeModeTo: newMode)
    }
}

extension PomodoroTimer {
    enum State {
        case running
        case paused
        case stopped
    }
    
    enum Mode: String {
        case focus = "Focus"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"
    }
}
