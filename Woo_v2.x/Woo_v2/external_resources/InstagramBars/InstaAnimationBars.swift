//
//  InstaAnimationBars.swift
//  AnimationBars
//
//  Created by Vaibhav Gautam on 31/07/16.
//  Copyright © 2016 Double You Tech. All rights reserved.
//

import UIKit

class InstaAnimationBars: UIView {
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createAndAnimateBars()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.createAndAnimateBars()
    }
    
    override func awakeFromNib() {
        print("Insta Animation called")
    }
    /**
     This is the main method which will do everything for you
     */
    func createAndAnimateBars() {
        
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let animationName = "strokeEnd"
        
        let pathForFirstBar:UIBezierPath = UIBezierPath()
        pathForFirstBar.move(to: CGPoint(x: 11, y: 29))
        pathForFirstBar.addLine(to: CGPoint(x: 11, y: 9))
        
        let shapeForFirstBar:CAShapeLayer = CAShapeLayer()
        shapeForFirstBar.path=pathForFirstBar.cgPath
        shapeForFirstBar.fillColor=UIColor.white.cgColor
        shapeForFirstBar.strokeColor=UIColor.white.cgColor
        shapeForFirstBar.lineWidth=4.0
        
        let firstBarAnimation:CABasicAnimation = CABasicAnimation(keyPath: animationName)
        firstBarAnimation.duration=0.4
        firstBarAnimation.fromValue=0.2
        firstBarAnimation.toValue=0.8
        firstBarAnimation.repeatCount=100000
        firstBarAnimation.isRemovedOnCompletion=false
        firstBarAnimation.autoreverses=true
        
        shapeForFirstBar.add(firstBarAnimation, forKey: animationName)
        
        self.layer.addSublayer(shapeForFirstBar)
        
        
        let pathForSecondBar:UIBezierPath = UIBezierPath()
        pathForSecondBar.move(to: CGPoint(x: 17, y: 29))
        pathForSecondBar.addLine(to: CGPoint(x: 17, y: 9))
        
        let shapeForSecondBar:CAShapeLayer = CAShapeLayer()
        shapeForSecondBar.path=pathForSecondBar.cgPath
        shapeForSecondBar.fillColor=UIColor.white.cgColor
        shapeForSecondBar.strokeColor=UIColor.white.cgColor
        shapeForSecondBar.lineWidth=4.0
        
        let secondBarAnimation:CABasicAnimation = CABasicAnimation(keyPath: animationName)
        secondBarAnimation.duration=0.5
        secondBarAnimation.fromValue=0.7
        secondBarAnimation.toValue=0.4
        secondBarAnimation.repeatCount=100000
        secondBarAnimation.isRemovedOnCompletion=false
        secondBarAnimation.autoreverses=true
        
        shapeForSecondBar.add(secondBarAnimation, forKey: animationName)
        
        self.layer.addSublayer(shapeForSecondBar)
        
        
        let pathForThirdBar:UIBezierPath = UIBezierPath()
        pathForThirdBar.move(to: CGPoint(x: 23, y: 29))
        pathForThirdBar.addLine(to: CGPoint(x: 23, y: 9))
        
        let shapeForThirdBar:CAShapeLayer = CAShapeLayer()
        shapeForThirdBar.path=pathForThirdBar.cgPath
        shapeForThirdBar.fillColor=UIColor.white.cgColor
        shapeForThirdBar.strokeColor=UIColor.white.cgColor
        shapeForThirdBar.lineWidth=4.0
        
        let thirdBarAnimation:CABasicAnimation = CABasicAnimation(keyPath: animationName)
        thirdBarAnimation.duration=0.5
        thirdBarAnimation.fromValue=0.4
        thirdBarAnimation.toValue=1.0
        thirdBarAnimation.repeatCount=100000
        thirdBarAnimation.isRemovedOnCompletion=false
        thirdBarAnimation.autoreverses=true
        
        shapeForThirdBar.add(thirdBarAnimation, forKey: animationName)
        
        self.layer.addSublayer(shapeForThirdBar)
        
        
        
    }
    
    
    
}
