//
//  PickerLabel.swift
//  pomodoro
//
//  Created by Augusto Avelino on 28/02/24.
//

import UIKit

class PickerLabel: UILabel {
    init() {
        super.init(frame: .zero)
        font = DSFonts.picker
        textAlignment = .center
        textColor = DSColors.primaryText
        transform = transform.rotated(by: .pi / 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
