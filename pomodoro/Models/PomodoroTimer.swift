//
//  PomodoroTimer.swift
//  pomodoro
//
//  Created by Augusto Avelino on 26/02/24.
//

import Foundation
import UserNotifications

/// Delegate protocol for receiving timer updates.
protocol PomodoroTimerDelegate: AnyObject {
    /// Called when the timer updates the elapsed time.
    /// - Tag: PomodoroTimerDelegate.didUpdateElapsedTime
    /// - Parameters:
    ///   - timer: The `PomodoroTimer` instance.
    ///   - elapsedTime: The updated elapsed time in seconds.
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval)
    
    /// Called when the timer is about to change its mode.
    /// - Tag: PomodoroTimerDelegate.willChangeModeFrom
    /// - Parameters:
    ///   - timer: The `PomodoroTimer` instance.
    ///   - currentMode: The current mode of the timer.
    ///   - newMode: The mode the timer is about to switch to.
    func pomodoroTimer(_ timer: PomodoroTimer, willChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode)
    
    /// Called when the timer has changed its mode.
    /// - Tag: PomodoroTimerDelegate.didChangeModeTo
    /// - Parameters:
    ///   - timer: The `PomodoroTimer` instance.
    ///   - currentMode: The new mode of the timer.
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeTo currentMode: PomodoroTimer.Mode)
}

extension PomodoroTimerDelegate {
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval) {}
    func pomodoroTimer(_ timer: PomodoroTimer, willChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode) {}
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeTo currentMode: PomodoroTimer.Mode) {}
}

/// An object that manages the timing functionality for a Pomodoro timer.
class PomodoroTimer {
    /// Pomodoro configuration, specifying durations for focus, short break, and long break sessions, along with the focus session limit.
    var configuration: PomodoroConfiguration
    
    /// Current state of the timer.
    private(set) var currentState: State
    
    /// Elapsed time since the timer started.
    /// - Tag: PomodoroTimer.elapsedTime
    private(set) var elapsedTime: TimeInterval
    
    /// Current mode of the timer.
    private(set) var currentMode: Mode
    
    /// Number of focus sessions completed.
    private var focusCount: Int = 0
    
    /// The timer object for managing the timer interval.
    private var timer: Timer?
    
    /// Delegate to receive updates about the timer.
    weak var delegate: PomodoroTimerDelegate?
    
    /// Initializes a new PomodoroTimer instance with the specified ``PomodoroConfiguration``.
    /// - Parameter configuration: Pomodoro configuration, specifying durations for focus, short break, and long break sessions, along with the
    /// number of focus sessions needed to take a long break.
    init(settings: PomodoroConfiguration) {
        self.configuration = settings
        self.elapsedTime = 0
        self.currentState = .stopped
        self.currentMode = .focus
    }
    
    /// Starts the timer.
    func start() {
        guard currentState != .running else { return }
        
        currentState = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.timerDidFire()
        }
    }
    
    /// Pauses the timer.
    func pause() {
        guard currentState == .running else { return }
        
        currentState = .paused
        timer?.invalidate()
    }
    
    /// Stops the timer and resets the elapsed time.
    func stop() {
        guard currentState != .stopped else { return }
        
        currentState = .stopped
        timer?.invalidate()
        elapsedTime = 0
    }
    
    /// Returns the duration for the specified mode.
    /// - Parameter mode: The mode for which to retrieve the duration.
    /// - Returns: The duration in seconds for the specified mode.
    func duration(for mode: Mode) -> TimeInterval {
        switch mode {
        case .focus:
            return configuration.focusDuration
        case .shortBreak:
            return configuration.shortBreakDuration
        case .longBreak:
            return configuration.longBreakDuration
        }
    }
    
    /// Sets the duration for the specified mode.
    /// - Parameters:
    ///   - duration: The duration in seconds.
    ///   - mode: The mode for which to set the duration.
    func setDuration(_ duration: TimeInterval, for mode: Mode) {
        switch mode {
        case .focus:
            configuration.focusDuration = duration
        case .shortBreak:
            configuration.shortBreakDuration = duration
        case .longBreak:
            configuration.longBreakDuration = duration
        }
    }

    /// Returns the time remaining in the current mode.
    /// - Returns: The time remaining in seconds.
    func currentTimeRemaining() -> TimeInterval {
        let currentDuration = duration(for: currentMode)
        return currentDuration - elapsedTime
    }

    /// Handler method called when the timer fires.
    /// Increments ``elapsedTime`` and completes the current mode if needed.
    /// This method calls  [`pomodoroTimer(_:didUpdateElapsedTime:)`](x-source-tag://PomodoroTimerDelegate.didUpdateElapsedTime) from
    /// the ``delegate``.
    private func timerDidFire() {
        if currentState == .running {
            elapsedTime += 1
            delegate?.pomodoroTimer(self, didUpdateElapsedTime: elapsedTime)
        }
        if currentTimeRemaining() <= 0 {
            modeCompleted()
        }
    }
    
    /// Private method to handle mode completion and trigger notifications.
    private func modeCompleted() {
        elapsedTime = 0
        let newMode: Mode
        switch currentMode {
        case .focus:
            focusCount += 1
            if focusCount < configuration.focusLimit {
                newMode = .shortBreak
            } else {
                focusCount = 0
                newMode = .longBreak
            }
        case .shortBreak:
            newMode = .focus
        case .longBreak:
            newMode = .focus
        }
        delegate?.pomodoroTimer(self, willChangeModeFrom: currentMode, to: newMode)
        currentMode = newMode
        delegate?.pomodoroTimer(self, didChangeModeTo: newMode)
    }
}

extension PomodoroTimer {
    /// Possible states of  a ``PomodoroTimer``.
    enum State {
        case running
        case paused
        case stopped
    }
    
    /// Possible modes of a ``PomodoroTimer``.
    enum Mode: String {
        case focus = "Focus"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"
    }
}
