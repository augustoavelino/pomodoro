//
//  DSColors.swift
//  pomodoro
//
//  Created by Augusto Avelino on 28/02/24.
//

import UIKit

enum DSColors {
    static let primaryText: UIColor = UIColor { traitCollection in
        if traitCollection.userInterfaceStyle == .light {
            return .black
        }
        return .white
    }
    static let secondaryText: UIColor = .systemGray2
    
    static let focus: UIColor = .systemBlue
    static let focusTint: UIColor = .systemGreen
    
    static let shortBreak: UIColor = .systemGreen
    static let shortBreakTint: UIColor = .systemMint
    
    static let longBreak: UIColor = .systemMint
    static let longBreakTint: UIColor = .systemBlue
    
    static let secondaryBackground: UIColor = .secondarySystemBackground
    static let secondaryTint: UIColor = .systemBlue
}
