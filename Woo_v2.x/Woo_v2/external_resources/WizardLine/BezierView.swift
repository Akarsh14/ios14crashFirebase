//
//  BezierView.swift
//  Bezier
//
//  Created by Ramsundar Shandilya on 10/14/15.
//  Copyright © 2015 Y Media Labs. All rights reserved.
//

import UIKit
import Foundation

protocol BezierViewDataSource: class {
    func bezierViewDataPoints(_ bezierView: BezierView) -> [CGPoint]
}

class BezierView: UIView {
   
    fileprivate let kStrokeAnimationKey = "StrokeAnimationKey"
    fileprivate let kFadeAnimationKey = "FadeAnimationKey"
    
    //MARK: Public members
    weak var dataSource: BezierViewDataSource?
    
    var lineColor = UIColor(red: 211.0/255.0, green: 199.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    
    var animates = true
    
    var pointLayers = [CAShapeLayer]()
    var lineLayer = CAShapeLayer()
    
    //MARK: Private members
    
    fileprivate var dataPoints: [CGPoint]? {
        return self.dataSource?.bezierViewDataPoints(self)
    }
    
    fileprivate let cubicCurveAlgorithm = CubicCurveAlgorithm()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.sublayers?.forEach({ (layer: CALayer) -> () in
            layer.removeFromSuperlayer()
        })
        pointLayers.removeAll()
        
        drawSmoothLines()
        animateLayers()
       // drawPoints()
    }
    
    fileprivate func drawPoints(){
        
        guard let points = dataPoints else {
            return
        }
        
        for point in points {
            
            let circleLayer = CAShapeLayer()
            circleLayer.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
            circleLayer.path = UIBezierPath(ovalIn: circleLayer.bounds).cgPath
            circleLayer.fillColor = UIColor(white: 248.0/255.0, alpha: 0.5).cgColor
            circleLayer.position = point
            
            circleLayer.shadowColor = UIColor.black.cgColor
            circleLayer.shadowOffset = CGSize(width: 0, height: 2)
            circleLayer.shadowOpacity = 0.7
            circleLayer.shadowRadius = 3.0
            
            self.layer.addSublayer(circleLayer)
            
            if animates {
                circleLayer.opacity = 0
                pointLayers.append(circleLayer)
            }
        }
    }
    
    fileprivate func drawSmoothLines() {
        
        guard let points = dataPoints else {
            return
        }
        
        let controlPoints = cubicCurveAlgorithm.controlPointsFromPoints(points)
        
        
        let linePath = UIBezierPath()
        
        for i in 0 ..< points.count {
            
            let point = points[i];
            
            if i==0 {
                linePath.move(to: point)
            } else {
                let segment = controlPoints[i-1]
                linePath.addCurve(to: point, controlPoint1: segment.controlPoint1, controlPoint2: segment.controlPoint2)
            }
        }
        
        lineLayer = CAShapeLayer()
        lineLayer.path = linePath.cgPath
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = 3.0
        
        
        lineLayer.shadowColor = UIColor.black.cgColor
        lineLayer.shadowOffset = CGSize(width: 0, height: 2)
        lineLayer.shadowOpacity = 0.2
        lineLayer.shadowRadius = 1.0
        
        
        self.layer.addSublayer(lineLayer)
        
        if animates {
            lineLayer.strokeEnd = 0
        }
    }
}

extension BezierView {
    
    func animateLayers() {
        animatePoints()
        animateLine()
    }
    
    func animatePoints() {
        
        var delay = 0.2
        
        for point in pointLayers {
            
            let fadeAnimation = CABasicAnimation(keyPath: "opacity")
            fadeAnimation.toValue = 1
            fadeAnimation.beginTime = CACurrentMediaTime() + delay
            fadeAnimation.duration = 0.2
            fadeAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            fadeAnimation.fillMode = CAMediaTimingFillMode.forwards
            fadeAnimation.isRemovedOnCompletion = false
            point.add(fadeAnimation, forKey: kFadeAnimationKey)
            
            delay += 0.15
        }
    }
    
    func animateLine() {
        
        let growAnimation = CABasicAnimation(keyPath: "strokeEnd")
        growAnimation.toValue = 1
        growAnimation.beginTime = CACurrentMediaTime() + 1.0
        growAnimation.duration = 1.0
        growAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        growAnimation.fillMode = CAMediaTimingFillMode.forwards
        growAnimation.isRemovedOnCompletion = false
        lineLayer.add(growAnimation, forKey: kStrokeAnimationKey)
    }
    
}

