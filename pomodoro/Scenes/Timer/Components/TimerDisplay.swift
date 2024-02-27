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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        return stackView
    }()
    
    private let minutesLabel: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = .monospacedDigitSystemFont(ofSize: 80.0, weight: .semibold)
        label.textColor = UIColor.white
        return label
    }()
    
    private let blinkingLabel: UILabel = {
        let label = UILabel()
        label.text = ":"
        label.font = .monospacedDigitSystemFont(ofSize: 80.0, weight: .semibold)
        label.textColor = UIColor.white
        return label
    }()
    
    private let secondsLabel: UILabel = {
        let label = UILabel()
        label.text = "00"
        label.font = .monospacedDigitSystemFont(ofSize: 80.0, weight: .semibold)
        label.textColor = UIColor.white
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
        setupStackView()
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
}
