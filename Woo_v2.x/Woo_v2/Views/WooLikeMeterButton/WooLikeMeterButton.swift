//
//  WooLikeMeterButton.swift
//  Woo_v2
//
//  Created by Suparno Bose on 13/06/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit
import SnapKit
import Darwin

class WooLikeMeterButton: UIButton {
    
    var isProgressbarVisible = true
    fileprivate var privateProgressValue : CGFloat = 0.0
    var progressValue : CGFloat{
        get{
            return self.privateProgressValue
        }
        set(value){
            if value > 100 {
                self.privateProgressValue = 100
            }
            else{
                self.privateProgressValue = value
            }
            
            if isProgressbarVisible {
                self.drawProgressBar()
            }
        }
    }
    
    var showProgress = false
    
    var redShapeLayer : CAShapeLayer? = nil
    
    var grayShapeLayer : CAShapeLayer? = nil
    
    override var isEnabled: Bool{
        get{
            return super.isEnabled
        }
        set(value){
            super.isEnabled = value
            drawProgressBar()
        }
    }
    
//    DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
    func degreeToRadian(_ degree: Float) -> Float {
        return (Float(M_PI)*degree/180)
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
//        self.progressValue = 40
    }
    
    func setProgressbarVisible(_ visible : Bool) {
        isProgressbarVisible = visible
        if isProgressbarVisible {
            drawProgressBar()
        }
        else{
            if redShapeLayer != nil {
                redShapeLayer!.removeFromSuperlayer()
                redShapeLayer = nil
            }
            if grayShapeLayer != nil {
                grayShapeLayer!.removeFromSuperlayer()
                grayShapeLayer = nil
            }
        }
    }
    
    func drawProgressBar() {
        
        if redShapeLayer != nil {
            redShapeLayer!.removeFromSuperlayer()
            redShapeLayer = nil
        }
        if grayShapeLayer != nil {
            grayShapeLayer!.removeFromSuperlayer()
            grayShapeLayer = nil
        }
        
        let radius = self.frame.width/2 - 4
        let progressUnit = CGFloat(2 * M_PI / 100)
        let progress = progressUnit * privateProgressValue
        
        let redCurveLine = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius - 2), radius: radius - 6.5, startAngle:CGFloat(-M_PI/2), endAngle: (progress - CGFloat(M_PI/2)), clockwise: true)
        redCurveLine.lineWidth = 2.0;
        UIColor.red.setStroke();
        
        redShapeLayer = CAShapeLayer()
        redShapeLayer!.path = redCurveLine.cgPath
        redShapeLayer!.fillColor = UIColor.clear.cgColor
        redShapeLayer!.strokeColor = kGrayColor
        redShapeLayer!.lineWidth = 2.0
        redShapeLayer!.lineCap = CAShapeLayerLineCap.round
        redShapeLayer!.position = CGPoint(x: self.bounds.midX-radius,
                                                 y: self.bounds.midY-radius);
        self.layer.addSublayer(redShapeLayer!)
        
        if privateProgressValue != 100 {
            let grayCurvedLine = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius - 2), radius: radius - 7, startAngle:(progress - CGFloat(M_PI/2)), endAngle: CGFloat(2*M_PI - M_PI/2), clockwise: true)
            grayCurvedLine.lineWidth = 2.0;
            UIColor.blue.setStroke();
            
            grayShapeLayer = CAShapeLayer()
            grayShapeLayer!.path = grayCurvedLine.cgPath
            grayShapeLayer!.fillColor = UIColor.clear.cgColor
            if self.isEnabled {
                grayShapeLayer!.strokeColor = kRedColor
            }
            else{
//                grayShapeLayer!.strokeColor = kRedColorDisbled
            }
            
            grayShapeLayer!.lineWidth = 2.0
            grayShapeLayer!.lineCap = CAShapeLayerLineCap.round
            grayShapeLayer!.position = CGPoint(x: self.bounds.midX-radius,
                                                   y: self.bounds.midY-radius);
            self.layer.addSublayer(grayShapeLayer!)
        }
    }
    
/// ----------- adding CA shaped layer

}
