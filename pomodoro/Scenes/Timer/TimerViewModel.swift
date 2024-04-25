//
//  TimerViewModel.swift
//  pomodoro
//
//  Created by Augusto Avelino on 11/03/24.
//

import Foundation

protocol TimerViewModelProtocol {
    // Getters
    func isStopped() -> Bool
    func timeRemaining() -> TimeInterval
    
    // Timer controls
    func startTimer()
    func pauseTimer()
    func stopTimer()
}

class TimerViewModel: TimerViewModelProtocol {
    private let pomodoroTimer: PomodoroTimer
    var timerDelegate: PomodoroTimerDelegate? {
        get { pomodoroTimer.delegate }
        set { pomodoroTimer.delegate = newValue }
    }
    
    init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
    }
    
    func isStopped() -> Bool {
        return pomodoroTimer.currentState == .stopped
    }
    
    func timeRemaining() -> TimeInterval {
        return pomodoroTimer.duration(for: pomodoroTimer.currentMode) - pomodoroTimer.elapsedTime
    }
    
    func getCurrentTimerState() -> PomodoroTimer.State {
        return pomodoroTimer.currentState
    }
    
    func startTimer() {
        pomodoroTimer.start()
    }
    
    func pauseTimer() {
        pomodoroTimer.pause()
    }
    
    func stopTimer() {
        pomodoroTimer.stop()
    }
}

//extension TimerViewModel: PomodoroTimerDelegate {
//    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval) {}
//    
//    func pomodoroTimer(_ timer: PomodoroTimer, willChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode) {}
//    
//    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeFrom previousMode: PomodoroTimer.Mode, to currentMode: PomodoroTimer.Mode) {}
//}
