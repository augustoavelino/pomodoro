//
//  TimerDisplay.swift
//  pomodoro
//
//  Created by Augusto Avelino on 22/02/24.
//

import UIKit

class TimerDisplay: UIView {
    
    // MARK: Properties
    
    private(set) var currentTime: TimeInterval = 0.0
    private var blinkingTimer: Timer?
    private var isBlinking = false
    
    // MARK: UI
    
    private let progressView: CircularProgressView = {
        let progressView = CircularProgressView(progressColor: .systemTeal, trackColor: .systemGray)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.accessibilityIdentifier = "timerDisplay.progressView"
        return progressView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        return stackView
    }()
    
    private let minutesLabel: UILabel = {
        let label = DisplayLabel(text: "00")
        label.accessibilityIdentifier = "timerDisplay.minutesLabel"
        return label
    }()
    private let blinkingLabel: UILabel = {
        let label = DisplayLabel(text: ":")
        label.accessibilityIdentifier = "timerDisplay.blinkingLabel"
        return label
    }()
    private let secondsLabel: UILabel = {
        let label = DisplayLabel(text: "00")
        label.accessibilityIdentifier = "timerDisplay.secondsLabel"
        return label
    }()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        setupProgressView()
        setupStackView()
    }
    
    private func setupProgressView() {
        addSubview(progressView)
        progressView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        progressView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        progressView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        progressView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    private func setupStackView() {
        addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        stackView.addArrangedSubview(minutesLabel)
        stackView.addArrangedSubview(blinkingLabel)
        stackView.addArrangedSubview(secondsLabel)
    }
    
    // MARK: - Setters
    
    func setTime(_ interval: TimeInterval) {
        currentTime = interval
        let minutes = Int(interval / 60)
        let seconds = Int(interval - TimeInterval(minutes * 60))
        minutesLabel.text = String(format: "%02d", minutes)
        secondsLabel.text = String(format: "%02d", seconds)
    }
    
    // MARK: - Display actions
    
    func startAnimations(progressDuration: TimeInterval) {
        startBlinking()
        
    }
    
    func startBlinking() {
        isBlinking = true
        blink()
        blinkingTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { [weak self] timer in
            guard let self = self else { return timer.invalidate() }
            self.blink()
        })
    }
    
    private func blink() {
        guard isBlinking else { return }
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseInOut) {
            self.blinkingLabel.alpha = 0.0
        }
        UIView.animate(withDuration: 0.1, delay: 1.0, options: .curveEaseInOut) {
            self.blinkingLabel.alpha = 1.0
        }
    }
    
    func stopBlinking() {
        isBlinking = false
        blinkingTimer?.invalidate()
        blinkingTimer = nil
    }
    
    /**
     Sets the progress of the circular progress indicator with optional animation.

     - Parameters:
        - progress: The progress value to be set, ranging from 0.0 to 1.0.
        - duration: Optional. The duration of the animation for updating the progress. If `duration` is greater than 0.0, the progress update is animated; otherwise, it's set immediately. Default is 0.0, indicating an immediate update.

     This method updates the progress of the circular progress indicator to the specified value. If `duration` is greater than 0.0, the update is animated using the default animation settings. If `duration` is 0.0 or less, the progress is set immediately without animation.
     */
    func setProgress(_ progress: Float, duration: TimeInterval = 0.0) {
        if duration > 0.0 {
            progressView.setProgressAnimated(progress, duration: duration)
        } else {
            progressView.setProgress(CGFloat(progress))
        }
    }
    
    func stopProgress() {
        progressView.stopAnimation()
    }
}

// MARK: - DisplayLabel

private class DisplayLabel: UILabel {
    init(text: String?) {
        super.init(frame: .zero)
        self.text = text
        font = DSFonts.timerDisplay
        textColor = DSColors.primaryText
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
