//
//  VoiceCallAudioManager.swift
//  Woo_v2
//
//  Created by Ankit Batra on 18/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

@objc class VoiceCallAudioManager: NSObject {
    
    var audioController: AudioController?
    @objc static let sharedInstance = VoiceCallAudioManager()

    @objc func configureAudioSession() {
        print("Configuring audio session")
        
        if audioController == nil {
            audioController = AudioController()
        }
    }
    
    @objc func startAudio() {
        print("Starting audio")
        
        if audioController?.startIOUnit() == kAudioServicesNoError {
            audioController?.muteAudio = false
//            audioController?.activateAudioSession(true);
        } else {
            // handle error
        }
    }
    
    @objc func stopAudio() {
        print("Stopping audio")
        
        if audioController?.stopIOUnit() != kAudioServicesNoError {
            // handle error
        }
//        else
//        {
//            audioController?.activateAudioSession(false);
//        }
    }
    
    @objc func startPlayingCallerTune()
    {
        audioController?.startPlayingCallerTune()
    }
    
    @objc func stopPlayingCallerTune()
    {
        audioController?.stopPlayingCallerTune()
    }
    
    @objc func playRingtone()
    {
        audioController?.playRingtone()
    }
    
    @objc func stopRingtone()
    {
        audioController?.stopRingtone()
    }
    
    @objc func activateAudioSession(activate:Bool) {
        audioController?.activateAudioSession(activate);
    }
}
