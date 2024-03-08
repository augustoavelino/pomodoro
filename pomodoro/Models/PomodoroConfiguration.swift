//
//  PomodoroConfiguration.swift
//  pomodoro
//
//  Created by Augusto Avelino on 29/02/24.
//

import Foundation

/// Encapsulates Pomodoro configuration including durations for focus, short break, and long break sessions.
struct PomodoroConfiguration {
    
    /// Duration of a focus session.
    var focusDuration: TimeInterval
    
    /// Duration of a short break session.
    var shortBreakDuration: TimeInterval
    
    /// Duration of a long break session.
    var longBreakDuration: TimeInterval
    
    /// Number of focus sessions before a long break starts.
    var focusLimit: Int
    
    /// A `PomodoroConfiguration` instance describing the default durations of a pomodoro.
    static var `default`: PomodoroConfiguration {
        PomodoroConfiguration(
            focusDuration: 1500.0, 
            shortBreakDuration: 300.0, 
            longBreakDuration: 900.0, 
            focusLimit: 4
        )
    }
}
