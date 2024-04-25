//
//  CircularProgressView.swift
//  pomodoro
//
//  Created by Augusto Avelino on 11/03/24.
//

import UIKit
import QuartzCore

class CircularProgressView: UIView {
    
    // MARK: Properties
    
    private let lineWidth: CGFloat
    
    var progressColor: UIColor {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor: UIColor {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    override var bounds: CGRect {
        didSet {
            drawLayers()
        }
    }
    
    /**
     A path that consists of straight and curved line segments that you can render in your custom views.
     Meaning our CAShapeLayer will now be drawn on the screen with the path we have specified here
     */
    private var viewCGPath: CGPath? {
        return UIBezierPath(
            arcCenter: CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0),
            radius: (bounds.size.width - 10)/2,
            startAngle: CGFloat(-0.5 * Double.pi),
            endAngle: CGFloat(1.5 * Double.pi),
            clockwise: true
        ).cgPath
    }
    
    // MARK: UI
    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    
    // MARK: - Life cycle
    
    init(lineWidth: CGFloat = 12.0, progressColor: UIColor, trackColor: UIColor) {
        self.lineWidth = lineWidth
        self.progressColor = progressColor
        self.trackColor = trackColor
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func drawLayers() {
        self.drawLayer(using: trackLayer, color: trackColor, ending: 1.0)
        self.drawLayer(using: progressLayer, color: progressColor, ending: 0.0, lineCap: .round)
    }
    
    private func drawLayer(using shape: CAShapeLayer, color: UIColor, ending: CGFloat, lineCap: CAShapeLayerLineCap = .butt) {
        shape.path = self.viewCGPath
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = color.cgColor
        shape.lineWidth = lineWidth
        shape.strokeEnd = ending
        shape.lineCap = lineCap
        shape.removeFromSuperlayer()
        self.layer.addSublayer(shape)
    }
    
    // MARK: - Setters
    
    /**
     Sets the progress of the circular progress indicator immediately without animation.

     - Parameter value: The progress value to be set, ranging from 0.0 to 1.0. The value should represent the desired progress state.
     */
    func setProgress(_ value: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = value
        CATransaction.commit()
    }
    
    /**
     Sets the progress of the circular progress indicator with animation.

     - Parameters:
        - value: The progress value to be set, ranging from 0.0 to 1.0. The value should represent the desired progress state.
        - duration: The duration of the animation for updating the progress.
        - curve: Optional. The timing function curve for the animation. Default is `linear`.

     This method updates the progress of the circular progress indicator to the specified value with animation. The update is animated over the specified `duration` using the specified timing function `curve`.
     */
    func setProgressAnimated(_ value: Float,  duration: TimeInterval, curve: CAMediaTimingFunctionName = .linear) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.isRemovedOnCompletion = true
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: curve)
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateCircle")
    }
    
    func stopAnimation() {
        progressLayer.removeAnimation(forKey: "strokeEnd")
    }
}
