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
    
    let pomodoroTimer = PomodoroTimer.default
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
        let button = UIButton(configuration: configuration)
        button.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        button.tintColor = .systemGreen
        return button
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        pomodoroTimer.delegate = self
    }
    
    deinit {
        timerDisplay.stopBlinking()
        pomodoroTimer.stop()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBlue
        title = pomodoroTimer.currentMode.rawValue
        setupTimerDisplay()
        setupPickerBackground()
        setupPickerViewData()
        setupPickerViewLayout()
        setupStartButton()
        setupStopButton()
    }
    
    private func setupTimerDisplay() {
        timerDisplay.setTime(pomodoroTimer.focusDuration)
        view.addSubview(timerDisplay)
        timerDisplay.translatesAutoresizingMaskIntoConstraints = false
        timerDisplay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        timerDisplay.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -16.0).isActive = true
        timerDisplay.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        timerDisplay.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
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
        pickerView.selectRow(14, inComponent: 0, animated: false)
        pickerView.selectRow(4, inComponent: 1, animated: false)
        pickerView.selectRow(24, inComponent: 2, animated: false)
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
        utter(content.body)
    }
    
    private func utter(_ string: String) {
        // Create an utterance.
        let utterance = AVSpeechUtterance(string: string)

        // Configure the utterance.
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8

        // Retrieve the British English voice.
        let voice = AVSpeechSynthesisVoice(language: "en-GB")

        // Assign the voice to the utterance.
        utterance.voice = voice
        
        synthesizer.speak(utterance)
    }
    
    func pomodoroTimer(_ timer: PomodoroTimer, didChangeModeTo currentMode: PomodoroTimer.Mode) {
        let newBackgroundColor: UIColor
        let newTintColor: UIColor
        switch currentMode {
        case .focus:
            newBackgroundColor = .systemBlue
            newTintColor = .systemGreen
        case .shortBreak:
            newBackgroundColor = .systemGreen
            newTintColor = .systemMint
        case .longBreak:
            newBackgroundColor = .systemMint
            newTintColor = .systemBlue
        }
        title = currentMode.rawValue
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
            self.view.backgroundColor = newBackgroundColor
            self.startButton.tintColor = newTintColor
            self.stopButton.tintColor = newTintColor
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
        if component == 2 {
            pomodoroTimer.focusDuration = TimeInterval(selectedValue) * 60
        } else if component == 1 {
            pomodoroTimer.shortBreakDuration = TimeInterval(selectedValue) * 60
        } else {
            pomodoroTimer.longBreakDuration = TimeInterval(selectedValue) * 60
        }
        updateTimerDisplay()
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label: UILabel
        if let reusing = view as? UILabel {
            label = reusing
        } else {
            label = UILabel()
            label.textColor = UIColor.white
            label.font = .systemFont(ofSize: 24, weight: .semibold, width: .expanded)
            label.textAlignment = .center
            label.transform = label.transform.rotated(by: .pi / 2)
        }
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
