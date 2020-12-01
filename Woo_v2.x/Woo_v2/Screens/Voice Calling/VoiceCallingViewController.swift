//
//  VoiceCallingViewController.swift
//  Woo_v2
//
//  Created by Ankit Batra on 07/06/17.
//  Copyright © 2017 Vaibhav Gautam. All rights reserved.
//

import UIKit

enum CallState:Int
{
    case incoming
    case outgoing
    case inCall
}

@objc class VoiceCallingViewController: UIViewController {

    @IBOutlet weak var bgGradientView: UIView!
    @IBOutlet weak var targetUserImage: UIImageView!
    @IBOutlet weak var targerUserName: UILabel!
    
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var outgoingCallSubview: UIView!
    
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var muteLabel: UILabel!
    @IBOutlet weak var speakerButton: UIButton!
    
    @IBOutlet weak var incomingCallSubview: UIView!
    
    
    var currentChannelKey : String?
    var currentChannelId : String?
    var matchDetail : MyMatches?
    var numberOfSeconds = 0
    var timer:Timer = Timer()
    var currentCallState : CallState = CallState.outgoing
    var matcheduserUid :UInt = 0;
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AgoraConnectionManager.shared().getIsAudioStreamMuted()
        AgoraConnectionManager.shared().getIsSpeakerOn()
        AgoraConnectionManager.shared().mute(false)
        
        //Check for microphone permission
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        let _ = AgoraConnectionManager.shared()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeStateToInCallForAcceptedCall), name: NSNotification.Name(rawValue: "outGoingCallInviteAccepted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStateToInCallForDeclinedCall), name: NSNotification.Name(rawValue: "outGoingCallInviteDeclined"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStateForInviteFailiure), name: NSNotification.Name(rawValue: "outGoingCallInviteFailiure"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleCurrentCallLeftByPeer), name: NSNotification.Name(rawValue: "currentCallLeftByPeer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleIncomingInviteCancelledByPeer), name: NSNotification.Name(rawValue:"incomingInviteCancelledByPeer"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleIncomingInviteCancelledByPeer), name: NSNotification.Name(rawValue:"currentCallEndedByReceiver"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(cancelOutgoingInvite), name: NSNotification.Name(rawValue:"cancelInvite"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(endCallAndDismissSelf), name: NSNotification.Name(rawValue:"endCall"), object: nil)
 
        // we don't do anything special in the route change notification
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: NSNotification.Name(rawValue:"AVAudioSessionRouteChangeNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleMuteStateChanged), name: NSNotification.Name(rawValue:"MuteStateChanged"), object: nil)

        
        // Do any additional setup after loading the view.
        if currentCallState == .incoming
        {
            incomingCallSubview.isHidden = false
            outgoingCallSubview.isHidden = true
            callStatus.text = "Calling ..."
        }
        else
        {
            muteButton.isSelected = false
            speakerButton.isSelected = false
            AgoraConnectionManager.shared().mute(false)
            AgoraConnectionManager.shared().speaker(false)

            incomingCallSubview.isHidden = true
            outgoingCallSubview.isHidden = false
            callStatus.text = "Ringing ..."
            
        }
        print("matchUserPic = \(String(describing: self.matchDetail?.matchUserPic))")
        targerUserName.text = self.matchDetail?.matchUserName
        NSLog("matchUserPic = \(String(describing: self.matchDetail?.matchUserPic))")
        
//        if(self.matchDetail?.matchGender ?? "" == "MALE")
//        {
            targetUserImage.sd_setImage(with: URL(string: self.matchDetail?.matchUserPic ?? ""), placeholderImage: UIImage(named: "ic_call_avatar"))
//        }
//        else
//        {
//            targetUserImage.sd_setImage(with: URL(string: self.matchDetail?.matchUserPic ?? ""), placeholderImage: UIImage(named: "female_placeholder_bigger"))
//
//        }

    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bgGradientView.bounds
        let topColor  = UIColor(red: (209.0/255.0), green: (73.0/255.0), blue: (100.0/255.0), alpha: 1.0).cgColor
        let middleColor  = UIColor(red: (169.0/255.0), green: (77.0/255.0), blue: (153.0/255.0), alpha: 1.0).cgColor
        let bottomColor  = UIColor(red: (134.0/255.0), green: (80.0/255.0), blue: (199.0/255.0), alpha: 1.0).cgColor
        gradientLayer.colors = [topColor,middleColor,bottomColor];
        bgGradientView.layer.insertSublayer(gradientLayer, at:0)
        targetUserImage.layer.cornerRadius =  targetUserImage.frame.size.height/2
        targetUserImage.layer.masksToBounds = true


    }
    @IBAction func muteButtonTapped(_ sender: UIButton)
    {
        if muteButton.isSelected
        {
            //unmute audio
            muteButton.isSelected = false
            
        }
        else{
            //mute audio
            muteButton.isSelected = true

        }
        AgoraConnectionManager.shared().mute(muteButton.isSelected)

    }
    @IBAction func speakerButtonTapped(_ sender: UIButton)
    {
        if speakerButton.isSelected
        {
            //unmute audio
            speakerButton.isSelected = false
        }
        else{
            //mute audio
            speakerButton.isSelected = true
        }
        AgoraConnectionManager.shared().speaker(speakerButton.isSelected)

    }
    @IBAction func outgoingCallCancelButtonTapped(_ sender: UIButton)
    {
        AgoraConnectionManager.shared().durationInSeconds =  NSNumber(value: numberOfSeconds);
        
        print("outgoingCallCancelButtonTapped")
        
        if (currentCallState == .outgoing)
        {
            //end outgoing call
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "CALLING_TAPS_ON_DISCONNET_INITIATED_CALL")
            let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when)
            {
                self.dismiss(animated: true)
                {
                    AgoraConnectionManager.shared().cancelInvite(forChannelId: self.currentChannelId, asUserWithAccount: self.matchDetail!.matchedUserId)
                    self.timer.invalidate()
                    
                    self.callStatus.text = "Call disconnected"
                    
                }
            }
        }
        else
        {
            //end ongoing call
            (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "CALLING_TAPS_ON_DISCONNET_CALL")

            let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
            DispatchQueue.main.async {
                self.callStatus.text = "Call disconnected"
                if(AgoraConnectionManager.shared().incomingCallChannelId == nil && AgoraConnectionManager.shared().callInititationTime != nil)
                {
                    AgoraConnectionManager.shared().logCallEventForCall(withMatchId: self.matchDetail!.matchId, wasCallDeclined: false, wasAnswered: true)
                }
                AgoraConnectionManager.shared().endOngoingCall(withChannelId: self.matchDetail!.matchId);
                self.timer.invalidate()

                DispatchQueue.main.asyncAfter(deadline: when)
                {
                    self.dismiss(animated: true)
                    
                }
            }
        }
    }
    
    @IBAction func incomingCallDeclineButtonTapped(_ sender: UIButton)
    {
        //Decline Call
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName: "CALLING_TAPS_ON_DECLINE_CALL")

        VoiceCallAudioManager.sharedInstance.stopPlayingCallerTune()
        AgoraConnectionManager.shared().declineInvite(withChannelId:self.currentChannelId,asUserWithAccount: self.matchDetail!.matchedUserId)
        self.timer.invalidate()
        self.dismiss(animated: true, completion: nil)
        
    }
   
    @IBAction func incomingCallAcceptButtonTapped(_ sender: UIButton)
    {
        
        (Utilities.sharedUtility() as! Utilities).sendFirebaseEvent(withScreenName: "", withEventName:"CALLING_TAPS_ON_ACCEPT_CALL")
        if(Utilities.sharedUtility() as! Utilities).checkMicrophonePermission() == 0
        {
            
            let verifiedAlert = AlertController.showAlert(withTitle: NSLocalizedString("Woo", comment: "Woo"), andMessage: NSLocalizedString("To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone.",comment: "To enable calls , Woo needs access to your iPhone's microphone. Tap settings and turn on Microphone"), needHandler: true, withController: self)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alertAction:UIAlertAction) in
                DispatchQueue.main.async
                    {
                        VoiceCallAudioManager.sharedInstance.stopPlayingCallerTune()
                        AgoraConnectionManager.shared().sendUserInstantMessage("Call disconnected", toAccount: self.matchDetail?.matchedUserId, withUid: 0)
                        
                        self.dismiss(animated: true)
                }
            })
            verifiedAlert.addAction(cancelAction)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default, handler: { (alertAction:UIAlertAction) in
                
                UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)

            })
            verifiedAlert.addAction(settingsAction)
            
            self.present(verifiedAlert, animated: true, completion: nil)
            
        }
        else if(Utilities.sharedUtility() as! Utilities).checkMicrophonePermission() == 1
        {
            AgoraConnectionManager.shared().getChannelKey(forMatchId: matchDetail!.matchId) { (response, completed) in
                    if (completed)
                    {
                        
                        if let responseDict = response as? [String:String]
                        {
                            MyMatches.updateMatchedUserDetails(forMatchedUserID: self.matchDetail!.matchedUserId , withAgoraChannelKey: responseDict["agora_channel_key"], withChatUpdationSuccess: { (completed) in
                                if (completed)
                                {
                                   self.matchDetail = MyMatches.getMatchDetail(forMatchedUSerID: self.matchDetail!.matchedUserId, isApplozic: false)

                                    VoiceCallAudioManager.sharedInstance.stopPlayingCallerTune()
                                    VoiceCallAudioManager.sharedInstance.stopRingtone()
                                    //Accept Call / Invite
                                    AgoraConnectionManager.shared().acceptInviteFromUser(withUid: 0, withChannelID: self.currentChannelId, asUserWithAccount: self.matchDetail!.matchedUserId, andMyChannelKey: self.matchDetail!.agoraChannelKey)
                                    DispatchQueue.main.async {
                                        self.changeCallStateTo(callState: .inCall)
                                    }
                                }
                            })
                        }
                }
            }
        }
        else
        {
            // == -1
            AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                if(granted)
                {
                    //permission granted 
                    //pick up call
                    AgoraConnectionManager.shared().getChannelKey(forMatchId: self.matchDetail!.matchId) { (response, completed) in
                        if (completed)
                        {
                            if let responseDict = response as? [String:String]
                            {
                                MyMatches.updateMatchedUserDetails(forMatchedUserID: self.matchDetail!.matchedUserId , withAgoraChannelKey: responseDict["agora_channel_key"], withChatUpdationSuccess: { (completed) in
                                    if (completed)
                                    {
                                        self.matchDetail = MyMatches.getMatchDetail(forMatchedUSerID: self.matchDetail!.matchedUserId, isApplozic: false)
                                        //Accept Call / Invite
                                        
                                        VoiceCallAudioManager.sharedInstance.stopPlayingCallerTune()
                                        VoiceCallAudioManager.sharedInstance.stopRingtone()
                                        
                                        AgoraConnectionManager.shared().acceptInviteFromUser(withUid: UInt32(self.matcheduserUid), withChannelID: self.currentChannelId, asUserWithAccount: self.matchDetail!.matchedUserId, andMyChannelKey: self.matchDetail!.agoraChannelKey)
                                        DispatchQueue.main.async {
                                            self.changeCallStateTo(callState: .inCall)
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            })
        }
    }
    
    func changeCallStateTo(callState state:CallState)
    {
        switch state {
        case .inCall:
            currentCallState = .inCall
            incomingCallSubview.isHidden = true
            outgoingCallSubview.isHidden = false
            callStatus.text = "00:00"
            numberOfSeconds = 0
//        if((VoiceCallAudioManager.sharedInstance.audioController?.getCurrentAVAudioSession().currentRoute.outputs.first)?.portName == "Speaker")
//            {
//                //Speaker is on
//                speakerButton.isSelected  = true
//                AgoraConnectionManager.shared().speaker(true)
//            }
//            else
//            {
//                //Speaker is on
//                speakerButton.isSelected  = false
//                AgoraConnectionManager.shared().speaker(false)
//            }
            
            
            speakerButton.isSelected  = false
            AgoraConnectionManager.shared().speaker(false)
            
            //Start Timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)

        default: break
            
        }
        
    }
    @objc func incrementTimer()
    {
        numberOfSeconds  =  numberOfSeconds + 1
        if(numberOfSeconds > 60)
        {
            let minutes = (numberOfSeconds/60) > 9 ? "\(numberOfSeconds/60)" : "0\(numberOfSeconds/60)"
            let seconds = (numberOfSeconds%60) > 9 ? "\(numberOfSeconds%60)" : "0\(numberOfSeconds%60)"

            self.callStatus.text = "\(minutes):\(seconds)"
            
        }
        else
        {
            self.callStatus.text = numberOfSeconds > 9 ? "00:\(numberOfSeconds)" : "00:0\(numberOfSeconds)"
        }
    }
    
    @objc func changeStateToInCallForAcceptedCall() {
        //Change call state in call
        DispatchQueue.main.async {
            self.changeCallStateTo(callState: .inCall)
        }
    }
    
    @objc func changeStateToInCallForDeclinedCall()
    {
       
        DispatchQueue.main.async {
            self.callStatus.text = "Call declined"
            let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
            AgoraConnectionManager.shared().leaveChannel(withId: self.matchDetail?.matchId)
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc func changeStateForInviteFailiure(notification : Notification)
    {
        let reason = notification.object as? String
        DispatchQueue.main.async {
            self.callStatus.text = reason ?? ""
            let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
            AgoraConnectionManager.shared().leaveChannel(withId: self.matchDetail?.matchId)
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.dismiss(animated: true)
            }
        }
    }
    
     @objc func handleCurrentCallLeftByPeer()
     {
        NSLog("handleCurrentCallLeftByPeer")
        
        
        AgoraConnectionManager.shared().durationInSeconds =  NSNumber(value: numberOfSeconds);
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.async {
            self.callStatus.text = "Call disconnected"
            if(AgoraConnectionManager.shared().incomingCallChannelId == nil && AgoraConnectionManager.shared().callInititationTime != nil)
            {
                AgoraConnectionManager.shared().logCallEventForCall(withMatchId: self.matchDetail!.matchId, wasCallDeclined: false, wasAnswered: true)
            }
            AgoraConnectionManager.shared().endOngoingCall(withChannelId:self.matchDetail?.matchId)
            self.timer.invalidate()
            DispatchQueue.main.asyncAfter(deadline: when)
            {
                self.dismiss(animated: true)
            }
        }
    }
    
    @objc func handleIncomingInviteCancelledByPeer()
    {
        
        DispatchQueue.main.async
            {
                self.callStatus.text = "Call disconnected"
                let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
                DispatchQueue.main.asyncAfter(deadline: when)
                {
                    self.dismiss(animated: true)
                }
        }

    }
    
    @objc func cancelOutgoingInvite(notification : Notification)
    {
        let reason = notification.object as? String
        DispatchQueue.main.async {
            self.callStatus.text = reason ?? ""
            AgoraConnectionManager.shared().cancelInvite(forChannelId: self.currentChannelId, asUserWithAccount: self.matchDetail!.matchedUserId)
            self.timer.invalidate()
            let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                self.muteButton.isSelected = false
                self.speakerButton.isSelected = false
                AgoraConnectionManager.shared().speaker(self.speakerButton.isSelected)
                self.dismiss(animated: true)

            }
        }
    }
    
    @objc func endCallAndDismissSelf(notification : Notification)
    {
        let reason = notification.object as? String
        DispatchQueue.main.async {
            self.callStatus.text = reason ?? ""
            self.timer.invalidate()
            let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
            DispatchQueue.main.asyncAfter(deadline: when) {
                
                
                self.muteButton.isSelected = false
                self.speakerButton.isSelected = false
                AgoraConnectionManager.shared().speaker(self.speakerButton.isSelected)
                self.dismiss(animated: true)
                
            }
        }
    }
    
     @objc func handleRouteChange(notification : Notification)
     {
        print("speaker portName is :%@",(VoiceCallAudioManager.sharedInstance.audioController?.getCurrentAVAudioSession().currentRoute.outputs.first)?.portName ?? "empty");
    if((VoiceCallAudioManager.sharedInstance.audioController?.getCurrentAVAudioSession().currentRoute.outputs.first)?.portName == "Speaker")
        {
            //Speaker is on
            print("Speaker is on")
            speakerButton.isSelected  = true
            AgoraConnectionManager.shared().speaker(true)
        }
        else
        {
            //Speaker is off
            print("Speaker is off")
            speakerButton.isSelected  = false
            AgoraConnectionManager.shared().speaker(false)
        }
    }
    
     @objc func handleMuteStateChanged()
     {
            muteButton.isSelected = AgoraConnectionManager.shared().getIsAudioStreamMuted()
        }
}

