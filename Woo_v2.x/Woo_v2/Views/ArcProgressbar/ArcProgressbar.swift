//
//  ArcProgressbar.swift
//  Woo_v2
//
//  Created by Suparno Bose on 05/07/16.
//  Copyright © 2016 Vaibhav Gautam. All rights reserved.
//

import UIKit

class ArcProgressbar: UIView {
    
    var isShownInWizard = false
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
            self.drawProgressBar()
        }
    }
    
    var redShapeLayer : CAShapeLayer? = nil
    
    var grayShapeLayer : CAShapeLayer? = nil
    
    //    DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
    func degreeToRadian(_ degree: Float) -> Float {
        return (Float(M_PI)*degree/180)
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        //self.drawProgressBar()
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
        let progressUnit = CGFloat(((2 * M_PI) - (M_PI / 3)) / 100)
        let progress = progressUnit * privateProgressValue
        
        let redCurveLine = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius + 2.0, startAngle:CGFloat(2*M_PI/3), endAngle: (CGFloat(M_PI/3)), clockwise: true)
        
        redCurveLine.lineWidth = 2.0;
        
        UIColor.red.setStroke();
        
        redShapeLayer = CAShapeLayer()
        redShapeLayer!.path = redCurveLine.cgPath
        redShapeLayer!.fillColor = UIColor.clear.cgColor
        if isShownInWizard{
            redShapeLayer!.strokeColor = UIColor.white.cgColor
            redShapeLayer!.lineWidth = 2.0
        }
        else{
            redShapeLayer!.strokeColor = kGrayColorDeep
            redShapeLayer!.lineWidth = 4.0
        }
        redShapeLayer!.lineCap = CAShapeLayerLineCap.round
        redShapeLayer!.position = CGPoint(x: self.bounds.midX-radius,
                                              y: self.bounds.midY-radius);
        self.layer.addSublayer(redShapeLayer!)
        
        
        let grayCurvedLine = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius + 2.0, startAngle:(CGFloat(2*M_PI/3)), endAngle: (CGFloat(2*M_PI/3) + progress), clockwise: true)
        grayCurvedLine.lineWidth = 2.0;
        UIColor.blue.setStroke();
        
        grayShapeLayer = CAShapeLayer()
        grayShapeLayer!.path = grayCurvedLine.cgPath
        grayShapeLayer!.fillColor = UIColor.clear.cgColor
        grayShapeLayer!.strokeColor = kRedArcColor
        
        grayShapeLayer!.lineCap = CAShapeLayerLineCap.round
        grayShapeLayer!.position = CGPoint(x: self.bounds.midX-radius,
                                               y: self.bounds.midY-radius);
        
        if isShownInWizard{
            grayShapeLayer?.strokeEnd = 0.0
            grayShapeLayer!.lineWidth = 6.0
        }
        else{
            grayShapeLayer!.lineWidth = 4.0
        }
        self.layer.addSublayer(grayShapeLayer!)
        self.setNeedsDisplay();
    }
    
    func animateCircle() {
        
        let growAnimation = CABasicAnimation(keyPath: "strokeEnd")
        growAnimation.fromValue = 0
        growAnimation.toValue = 1
        growAnimation.beginTime = CACurrentMediaTime() + 0.0
        growAnimation.duration = 1.5
        growAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        growAnimation.fillMode = CAMediaTimingFillMode.forwards
        growAnimation.isRemovedOnCompletion = false
        grayShapeLayer?.strokeEnd = 1.0
        grayShapeLayer?.add(growAnimation, forKey: "animateCircle")
    }
}
