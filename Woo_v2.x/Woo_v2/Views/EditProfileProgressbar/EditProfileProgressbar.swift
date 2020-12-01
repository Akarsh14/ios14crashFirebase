//
//  EditProfileProgressbar.swift
//  Woo_v2
//
//  Created by Suparno Bose on 05/07/16.
//  Copyright © 2016 Woo. All rights reserved.
//

import UIKit

class EditProfileProgressbar: UIImageView {
    fileprivate var privateprogressBarWidth : CGFloat = 6.0
    fileprivate var remainingProgressColor: UIColor = UIColor.clear      //Addded by Umesh
    var progressBarWidth :CGFloat{
        get{
            return self.privateprogressBarWidth
        }
        set(value){
            if value > 100 {
                self.privateprogressBarWidth = 100
            }
            else{
                self.privateprogressBarWidth = value
            }
            self.drawProgressBar()
        }
    }
    
    fileprivate var privateProgressValue : CGFloat = 0.0
    @objc var progressValue : CGFloat{
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
    var redShapeLayerRemaining : CAShapeLayer? = nil        //Addded by Umesh
    

    //    DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0)
    func degreeToRadian(_ degree: Float) -> Float {
        return (Float(M_PI)*degree/180)
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        self.drawProgressBar()
    }
    
    func drawProgressBar() {
        if redShapeLayer != nil {
            redShapeLayer!.removeFromSuperlayer()
            redShapeLayer = nil
        }
        
        let radius = self.frame.width/2 + 1
        let progressUnit = CGFloat(2 * M_PI / 100)
        let progress = progressUnit * privateProgressValue
        
        let progressBackground = progressUnit * 100     //Addded by Umesh
        
        let redCurveLine = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius - 6.5, startAngle:CGFloat(-M_PI/2), endAngle: (progress - CGFloat(M_PI/2)), clockwise: true)
        //Addded by Umesh
        let backgroundCurveLine = UIBezierPath(arcCenter: CGPoint(x: radius, y: radius), radius: radius - 6.5, startAngle:CGFloat(-M_PI/2), endAngle: (progressBackground - CGFloat(M_PI/2)), clockwise: true)
        backgroundCurveLine.lineWidth = 3.0
        //Addded by Umesh ENds
        
        redCurveLine.lineWidth = 3.0;
        
        
        UIColor.red.setStroke();
        
        
        //Addded by Umesh
        redShapeLayerRemaining = CAShapeLayer()
        redShapeLayerRemaining!.path = backgroundCurveLine.cgPath
        redShapeLayerRemaining!.fillColor = UIColor.clear.cgColor
        redShapeLayerRemaining!.strokeColor = remainingProgressColor.cgColor
        redShapeLayerRemaining!.lineWidth = privateprogressBarWidth
        redShapeLayerRemaining!.lineCap = CAShapeLayerLineCap.square
        redShapeLayerRemaining!.position = CGPoint(x: self.bounds.midX-radius,
                                              y: self.bounds.midY-radius);
        self.layer.addSublayer(redShapeLayerRemaining!)
        //Addded by Umesh Ends
        
        redShapeLayer = CAShapeLayer()
        redShapeLayer!.path = redCurveLine.cgPath
        redShapeLayer!.fillColor = UIColor.clear.cgColor
        redShapeLayer!.strokeColor = kSeaBlueColor
        redShapeLayer!.lineWidth = privateprogressBarWidth
        redShapeLayer!.lineCap = CAShapeLayerLineCap.square
        redShapeLayer!.position = CGPoint(x: self.bounds.midX-radius,
                                              y: self.bounds.midY-radius);
        self.layer.addSublayer(redShapeLayer!)
        
        self.setNeedsDisplay()
    }
    //Addded by Umesh
    func setFillColorVarlue(_ userFillColor:UIColor) -> Void {
        remainingProgressColor = userFillColor
    }
    //Addded by Umesh Ends
}
