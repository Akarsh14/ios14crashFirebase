//
//  OutOfLikeView.swift
//  Woo_v2
//
//  Created by Suparno Bose on 06/10/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class OutOfLikeView: UIView {

    @IBOutlet weak var wooPlusButton: UIButton!
    
    @IBOutlet weak var timerLabel: UILabel!
    
    var buttonPressHandler : (() -> ())!
    var dismissHandler : (() -> ())!
    var currentTime = 0
    
    var timer : Timer?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func didMoveToSuperview(){
        super.didMoveToSuperview()
        calculateTime()
        showTimerText()
    }
    
    @IBAction func closePopupView(_ sender: AnyObject) {
        
        self.removeFromSuperview()
        if(dismissHandler != nil)
        {
            dismissHandler!()
        }
        if sender as! UIButton == wooPlusButton {
            if buttonPressHandler != nil {
                buttonPressHandler!()
            }
        }
    }
    
    class func showView(parentViewController : UIViewController) -> OutOfLikeView{
        let outOfLikePopup: OutOfLikeView =
            Bundle.main.loadNibNamed("OutOfLikeView", owner: parentViewController, options: nil)!.first as! OutOfLikeView
        parentViewController.view.addSubview(outOfLikePopup)
        outOfLikePopup.frame = parentViewController.view.frame
        
        NotificationCenter.default.addObserver(outOfLikePopup, selector: #selector(resetTimer), name: NSNotification.Name(rawValue: "UIApplicationWillEnterForegroundNotification"), object: nil)
        
        NotificationCenter.default.addObserver(outOfLikePopup, selector: #selector(stopTimer), name: NSNotification.Name(rawValue: "UIApplicationDidEnterBackgroundNotification"), object: nil)
        
        return outOfLikePopup
    }
    
    func calculateTime() {
        let date = NSDate()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date as Date)
        let hour = components.hour
        let minutes = components.minute
        let second = components.second
        
        currentTime = 24*60*60 - ((((hour! * 60) + minutes! ) * 60 ) + second!)
    }
    
    @objc func showTimerText() {
        currentTime -= 1
        
        var timerText : String = ""
        let hour = "\(currentTime / 3600)"
        if hour.count == 2 {
            timerText += hour
        }
        else{
            timerText = "0" + hour
        }
        
        timerText += " : "
        
        let minute = "\((currentTime / 60) % 60)"
        if minute.count == 2 {
            timerText += minute
        }
        else{
            timerText = timerText + "0" + minute
        }
        
        timerText += " : "
        
        let second = "\(currentTime % 60)"
        if second.count == 2 {
            timerText += second
        }
        else{
            timerText = timerText + "0" + second
        }
        
        timerLabel.text = timerText
        
        if currentTime == 0 {
            self.removeView()
            return
        }
        
        if #available(iOS 10.0, *) {
          timer =  Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                self.showTimerText()
            }
        } else {
          timer =  Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(showTimerText), userInfo: nil, repeats: false)
        }
    }
    
    func removeView() {
        self.removeFromSuperview()
    }
    
    @objc func resetTimer() {
        calculateTime()
        
        showTimerText()
    }
    
    @objc func stopTimer() {
        timer?.invalidate()
        timer = nil
        
        currentTime = 0
    }
}
