//
//  AVSpeechSynthesizer+Extensions.swift
//  pomodoro
//
//  Created by Augusto Avelino on 28/02/24.
//

import AVFoundation

extension AVSpeechSynthesizer {
    func utter(
        _ string: String,
        rate: Float = AVSpeechUtteranceDefaultSpeechRate,
        pitchMultiplier: Float = 0.8,
        postUtteranceDelay: TimeInterval = 0.2,
        volume: Float = 1.0
    ) {
        let utterance = AVSpeechUtterance(string: string)
        utterance.rate = rate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.postUtteranceDelay = postUtteranceDelay
        utterance.volume = volume
        speak(utterance)
    }
}
