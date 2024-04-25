//
//  TimerViewController.swift
//  pomodoro
//
//  Created by Augusto Avelino on 19/02/24.
//

import UIKit
import AVFoundation

class TimerViewController: UIViewController {
    
    // MARK: Properties
    
    let viewModel: TimerViewModelProtocol
    let synthesizer = AVSpeechSynthesizer()
    
    // MARK: UI
    
    private let timerDisplay = TimerDisplay()
    
    private let startButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 20.0, leading: 20.0, bottom: 20.0, trailing: 20.0)
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 28)
        let button = UIButton(configuration: configuration)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.setImage(UIImage(systemName: "pause.fill"), for: .selected)
        button.tintColor = .systemGreen
        return button
    }()
    
    private let stopButton: UIButton = {
        var configuration = UIButton.Configuration.tinted()
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16.0, leading: 16.0, bottom: 16.0, trailing: 16.0)
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24)
        configuration.image = UIImage(systemName: "stop.fill")
        let button = UIButton(configuration: configuration)
        button.tintColor = .systemGreen
        return button
    }()
    
    // MARK: - Life cycle
    
    init(viewModel: TimerViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerDisplay.setProgress(1.0)
    }
    
    deinit {
        timerDisplay.stopBlinking()
        viewModel.stopTimer()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = DSColors.focus
        setupTimerDisplay()
        setupStartButton()
        setupStopButton()
        updateTimerDisplay()
    }
    
    private func setupTimerDisplay() {
        view.addSubview(timerDisplay)
        timerDisplay.translatesAutoresizingMaskIntoConstraints = false
        timerDisplay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        timerDisplay.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -16.0).isActive = true
        timerDisplay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 48.0).isActive = true
        timerDisplay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48.0).isActive = true
    }
    
    private func setupStartButton() {
        startButton.addTarget(self, action: #selector(onStartTap), for: .touchUpInside)
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24.0).isActive = true
    }
    
    private func setupStopButton() {
        stopButton.addTarget(self, action: #selector(onStopTap), for: .touchUpInside)
        view.addSubview(stopButton)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.leadingAnchor.constraint(equalTo: startButton.trailingAnchor, constant: 8).isActive = true
        stopButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor).isActive = true
    }
    
    fileprivate func updateTimerDisplay() {
        timerDisplay.setTime(viewModel.timeRemaining())
    }
    
    // MARK: - Actions
    
    @objc private func onStartTap(_ sender: UIButton) {
        if !sender.isSelected {
            viewModel.startTimer()
            timerDisplay.startBlinking()
            timerDisplay.setProgress(1.0, duration: viewModel.timeRemaining())
        } else {
            viewModel.pauseTimer()
            timerDisplay.stopBlinking()
            timerDisplay.stopProgress()
        }
        sender.isSelected.toggle()
    }
    
    @objc private func onStopTap(_ sender: UIButton) {
        startButton.isSelected = false
        viewModel.stopTimer()
        timerDisplay.stopBlinking()
        updateTimerDisplay()
    }
}

// MARK: - PomodoroTimerDelegate

extension TimerViewController: PomodoroTimerDelegate {
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval) {
        updateTimerDisplay()
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, willChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode) {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro"
        content.body = "Your \(currentMode.rawValue) session has ended."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "PomodoroTimerNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        synthesizer.utter(content.body)
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode) {
        let colors = modeColors(currentMode: timer.currentMode)
        title = timer.currentMode.rawValue
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
            self.view.backgroundColor = colors.background
            self.startButton.tintColor = colors.tint
            self.stopButton.tintColor = colors.tint
        }
    }
    
    private func modeColors(currentMode: PomodoroTimer.Mode) -> (background: UIColor, tint: UIColor) {
        switch currentMode {
        case .focus: return (DSColors.focus, DSColors.focusTint)
        case .shortBreak: return (DSColors.shortBreak, DSColors.shortBreakTint)
        case .longBreak: return (DSColors.longBreak, DSColors.longBreakTint)
        }
    }
}
