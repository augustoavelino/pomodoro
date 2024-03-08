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
    
    let pomodoroTimer: PomodoroTimer
    let synthesizer = AVSpeechSynthesizer()
    
    // MARK: UI
    
    private let timerDisplay = TimerDisplay()
    
    private let pickerBackground: UIView = {
        let pickerBackgroundView = UIView()
        pickerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        return pickerBackgroundView
    }()
    
    private let pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
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
    
    init(pomodoroTimer: PomodoroTimer) {
        self.pomodoroTimer = pomodoroTimer
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadData()
        pomodoroTimer.delegate = self
    }
    
    deinit {
        timerDisplay.stopBlinking()
        pomodoroTimer.stop()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = pomodoroTimer.currentMode.rawValue
        view.backgroundColor = DSColors.focus
        setupTimerDisplay()
        setupPickerView()
        setupStartButton()
        setupStopButton()
    }
    
    private func loadData() {
        pomodoroTimer.configuration = .default
        pickerView.reloadAllComponents()
        updateTimerDisplay()
    }
    
    private func setupTimerDisplay() {
        timerDisplay.setTime(pomodoroTimer.duration(for: .focus))
        view.addSubview(timerDisplay)
        timerDisplay.translatesAutoresizingMaskIntoConstraints = false
        timerDisplay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        timerDisplay.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -16.0).isActive = true
        timerDisplay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        timerDisplay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setupPickerView() {
        setupPickerBackground()
        setupPickerViewData()
        setupPickerViewLayout()
    }
    
    private func setupPickerBackground() {
        view.addSubview(pickerBackground)
        pickerBackground.heightAnchor.constraint(equalToConstant: 360.0).isActive = true
        pickerBackground.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pickerBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pickerBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func setupPickerViewData() {
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow((Int(pomodoroTimer.duration(for: .longBreak)) / 60) - 1, inComponent: 0, animated: false)
        pickerView.selectRow((Int(pomodoroTimer.duration(for: .shortBreak)) / 60) - 1, inComponent: 1, animated: false)
        pickerView.selectRow((Int(pomodoroTimer.duration(for: .focus)) / 60) - 1, inComponent: 2, animated: false)
    }
    
    private func setupPickerViewLayout() {
        pickerBackground.addSubview(pickerView)
        pickerView.centerXAnchor.constraint(equalTo: pickerBackground.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: pickerBackground.centerYAnchor).isActive = true
        pickerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        pickerView.widthAnchor.constraint(equalToConstant: 360.0).isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        pickerView.transform = pickerView.transform.rotated(by: -.pi / 2)
    }
    
    private func setupStartButton() {
        startButton.addTarget(self, action: #selector(onStartTap), for: .touchUpInside)
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.bottomAnchor.constraint(equalTo: pickerBackground.topAnchor, constant: -20.0).isActive = true
    }
    
    private func setupStopButton() {
        stopButton.addTarget(self, action: #selector(onStopTap), for: .touchUpInside)
        view.addSubview(stopButton)
        stopButton.translatesAutoresizingMaskIntoConstraints = false
        stopButton.leadingAnchor.constraint(equalTo: startButton.trailingAnchor, constant: 8).isActive = true
        stopButton.centerYAnchor.constraint(equalTo: startButton.centerYAnchor).isActive = true
    }
    
    fileprivate func updateTimerDisplay() {
        timerDisplay.setTime(pomodoroTimer.currentTimeRemaining())
    }
    
    // MARK: - Actions
    
    @objc private func onStartTap(_ sender: UIButton) {
        if !sender.isSelected {
            pomodoroTimer.start()
            timerDisplay.startBlinking()
        } else {
            pomodoroTimer.pause()
            timerDisplay.stopBlinking()
        }
        sender.isSelected.toggle()
        pickerView.isUserInteractionEnabled = pomodoroTimer.currentState == .stopped
    }
    
    @objc private func onStopTap(_ sender: UIButton) {
        startButton.isSelected = false
        pomodoroTimer.stop()
        timerDisplay.stopBlinking()
        pickerView.isUserInteractionEnabled = pomodoroTimer.currentState == .stopped
        updateTimerDisplay()
    }
}

// MARK: - PomodoroTimerDelegate

extension TimerViewController: PomodoroTimerDelegate {
    func pomodoroTimer(_ timer: PomodoroTimer, willChangeModeFrom currentMode: PomodoroTimer.Mode, to newMode: PomodoroTimer.Mode) {
        let content = UNMutableNotificationContent()
        content.title = "Pomodoro"
        content.body = "Your \(currentMode.rawValue) session has ended."
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "PomodoroTimerNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        synthesizer.utter(content.body)
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeTo currentMode: PomodoroTimer.Mode) {
        let colors = modeColors(currentMode: currentMode)
        title = currentMode.rawValue
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
    
    func pomodoroTimer(_ timer: PomodoroTimer, didUpdateElapsedTime elapsedTime: TimeInterval) {
        updateTimerDisplay()
    }
}

// MARK: - UIPickerViewDelegate

extension TimerViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedValue = row + 1
        let duration = TimeInterval(selectedValue) * 60
        let mode: PomodoroTimer.Mode = switch component {
        case 2: .focus
        case 1: .shortBreak
        default: .longBreak
        }
        pomodoroTimer.setDuration(duration, for: mode)
        updateTimerDisplay()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel = (view as? PickerLabel) ?? PickerLabel()
        label.text = "\(row + 1)"
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 120.0
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 64.0
    }
}

// MARK: - UIPickerViewDataSource

extension TimerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 60
    }
}
