//
//  EditBorderView.swift
//  SobrCameraView-Example
//
//  Created by Silas Knobel on 17/06/15.
//  Copyright (c) 2015 Software Brauerei AG. All rights reserved.
//

import UIKit

// CGPoints Illustraition
//
//            cd
//  d   -------------   c
//     |             |
//     |             |
//  da |             |  bc
//     |             |
//     |             |
//     |             |
//  a   -------------   b
//            ab
//
// a = 1, b = 2, c = 3, d = 4

public struct CornerPoints: DebugPrintable {
    var topLeft: CGPoint = CGPointZero
    var topRight: CGPoint = CGPointZero
    var bottomRight: CGPoint = CGPointZero
    var bottomLeft: CGPoint = CGPointZero
    
    
    public var debugDescription: String {
        return "<CornerPoints> tl: \(self.topLeft), tr: \(self.topRight), bl: \(self.bottomLeft), br: \(self.bottomRight)"
    }
}

public class EditBorderView: UIView {
    
    //MARK: Properties    
    public var cornerPoints: CornerPoints? {
        didSet {
            debugPrintln(self.cornerPoints)
            self.alignPoints()
            self.needsRedraw()
        }
    }
    
    
    private(set) var frameMoved: Bool = false
    
    private var pointA: CGPoint = CGPointZero
    private var pointB: CGPoint = CGPointZero
    private var pointC: CGPoint = CGPointZero
    private var pointD: CGPoint = CGPointZero
    private var touchOffset: CGPoint = CGPointZero
    
    private var topLeftButton: UIButton!
    private var topRightButton: UIButton!
    private var bottomLeftButton: UIButton!
    private var bottomRightButton: UIButton!
    
    //MARK: Life cycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = false
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = true
        self.contentMode = .Redraw
        self.initButtons()
        
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = false
        self.backgroundColor = UIColor.clearColor()
        self.userInteractionEnabled = true
        self.contentMode = .Redraw
        self.initButtons()
    }
    
    public override func drawRect(rect: CGRect) {
        if let currentContext = UIGraphicsGetCurrentContext() {
            CGContextSetRGBFillColor(currentContext, 0, 0, 0, 0.7)
            CGContextSetRGBStrokeColor(currentContext, 1, 0.43, 0.08, 1.0)
            CGContextSetLineJoin(currentContext, kCGLineJoinRound)
            CGContextSetLineWidth(currentContext, 4.0)
            
            let boundingRect = CGContextGetClipBoundingBox(currentContext)
            CGContextAddRect(currentContext, boundingRect)
            CGContextFillRect(currentContext, boundingRect)
            
            
            //draw path
            var pathRef = CGPathCreateMutable()
            CGPathMoveToPoint(pathRef, nil, self.pointA.x, self.pointA.y)
            CGPathAddLineToPoint(pathRef, nil, self.pointB.x, self.pointB.y)
            CGPathAddLineToPoint(pathRef, nil, self.pointC.x, self.pointC.y)
            CGPathAddLineToPoint(pathRef, nil, self.pointD.x, self.pointD.y)
            CGPathCloseSubpath(pathRef)
            
            
            CGContextAddPath(currentContext, pathRef)
            CGContextStrokePath(currentContext)
            CGContextSetBlendMode(currentContext, kCGBlendModeClear)
            
            CGContextAddPath(currentContext, pathRef)
            CGContextFillPath(currentContext)
            
            CGContextSetBlendMode(currentContext, kCGBlendModeNormal)
        }
        
    }
    
    public func resetFrame() {
        self.alignPoints()
        self.setNeedsDisplay()
        self.drawRect(self.bounds)
        self.frameMoved = false
        self.alignButtons()
    }
    
    private func needsRedraw() {
        self.frameMoved = true
        self.setNeedsDisplay()
        self.alignButtons()
        self.drawRect(self.bounds)
    }
    
    private func alignPoints() {
        if let feature = self.cornerPoints {
            self.pointA = feature.bottomLeft
            self.pointB = feature.bottomRight
            self.pointC = feature.topRight
            self.pointD = feature.topLeft
        }
    }
    
    private func alignButtons() {
        let cropButtonSize = CGFloat(200.0)
        self.topLeftButton.frame = CGRect(x: ((self.pointD.x - cropButtonSize) / 2), y: ((self.pointD.y - cropButtonSize) / 2), width: cropButtonSize, height: cropButtonSize)
        self.topRightButton.frame = CGRect(x: self.pointC.x - cropButtonSize / 2 , y: self.pointC.y - cropButtonSize / 2, width: cropButtonSize, height: cropButtonSize)
        self.bottomLeftButton.frame = CGRect(x: self.pointA.x - cropButtonSize / 2 , y: self.pointA.y - cropButtonSize / 2, width: cropButtonSize, height: cropButtonSize)
        self.bottomRightButton.frame = CGRect(x: self.pointB.x - cropButtonSize / 2 , y: self.pointB.y - cropButtonSize / 2, width: cropButtonSize, height: cropButtonSize)
    }
    
    private func initButtons() {
        self.topLeftButton  = UIButton.buttonWithType(.Custom) as! UIButton
        self.topLeftButton.tag = 4
        self.topLeftButton.showsTouchWhenHighlighted = false
        self.topLeftButton.addTarget(self, action: Selector("pointMoved:forEvent:"), forControlEvents: .TouchDragInside)
        self.topLeftButton.addTarget(self, action: Selector("pointMoveEnter:forEvent:"), forControlEvents: .TouchDown)
        self.topLeftButton.addTarget(self, action: Selector("pointMoveExit:forEvent:"), forControlEvents: .TouchDragExit)
        self.addSubview(self.topLeftButton)
        
        self.topRightButton  = UIButton.buttonWithType(.Custom) as! UIButton
        self.topRightButton.tag = 3
        self.topRightButton.showsTouchWhenHighlighted = false
        self.topRightButton.addTarget(self, action: Selector("pointMoved:forEvent:"), forControlEvents: .TouchDragInside)
        self.topRightButton.addTarget(self, action: Selector("pointMoveEnter:forEvent:"), forControlEvents: .TouchDown)
        self.topRightButton.addTarget(self, action: Selector("pointMoveExit:forEvent:"), forControlEvents: .TouchDragExit)
        self.addSubview(self.topRightButton)
        
        self.bottomRightButton  = UIButton.buttonWithType(.Custom) as! UIButton
        self.bottomRightButton.tag = 2
        self.bottomRightButton.showsTouchWhenHighlighted = false
        self.bottomRightButton.addTarget(self, action: Selector("pointMoved:forEvent:"), forControlEvents: .TouchDragInside)
        self.bottomRightButton.addTarget(self, action: Selector("pointMoveEnter:forEvent:"), forControlEvents: .TouchDown)
        self.bottomRightButton.addTarget(self, action: Selector("pointMoveExit:forEvent:"), forControlEvents: .TouchDragExit)
        self.addSubview(self.bottomRightButton)
        
        self.bottomLeftButton  = UIButton.buttonWithType(.Custom) as! UIButton
        self.bottomLeftButton.tag = 1
        self.bottomLeftButton.showsTouchWhenHighlighted = false
        self.bottomLeftButton.addTarget(self, action: Selector("pointMoved:forEvent:"), forControlEvents: .TouchDragInside)
        self.bottomLeftButton.addTarget(self, action: Selector("pointMoveEnter:forEvent:"), forControlEvents: .TouchDown)
        self.bottomLeftButton.addTarget(self, action: Selector("pointMoveExit:forEvent:"), forControlEvents: .TouchDragExit)
        self.addSubview(self.bottomLeftButton)
        self.alignButtons()
    }
    
    //MARK: Private Helper
    public func pointMoveEnter(sender: UIControl, forEvent event: UIEvent) {
        let rawPoint = (event.allTouches()?.first as! UITouch).locationInView(self)
        self.touchOffset = CGPoint(x: (rawPoint.x - sender.center.x), y: (rawPoint.y - sender.center.y))
    }
    
    public func pointMoved(sender: UIControl, forEvent event: UIEvent) {
        let rawPoint = (event.allTouches()?.first as! UITouch).locationInView(self)
        var point = CGPoint(x: (rawPoint.x - self.touchOffset.x), y: (rawPoint.y - self.touchOffset.y))
        
        if !CGRectContainsPoint(self.bounds, point) {
            let lineOffsetWidth = CGFloat(2.0)
            if point.x < lineOffsetWidth || point.x > (self.bounds.size.width - lineOffsetWidth) {
                if point.x < lineOffsetWidth {
                    point.x = lineOffsetWidth
                }
                else if point.x > (self.bounds.size.width - lineOffsetWidth) {
                    point.x = self.bounds.size.width - lineOffsetWidth
                }
            }
            
            if point.y < lineOffsetWidth || point.y > (self.bounds.size.height - lineOffsetWidth) {
                if point.y < lineOffsetWidth {
                    point.y = lineOffsetWidth
                }
                else if point.y > self.bounds.size.height {
                    point.y = self.bounds.size.height - lineOffsetWidth
                }
            }
        }
        
        self.frameMoved = true
        sender.center = point
        
        switch sender.tag {
        case 1:
            self.pointA = point
        case 2:
            self.pointB = point
        case 3:
            self.pointC = point
        case 4:
            self.pointD = point
        default:
            debugPrintln("no point found...")
        }
        
        self.setNeedsDisplay()
        self.drawRect(self.bounds)
    }
    
    public func pointMoveExit(sender: UIControl, forEvent event: UIEvent) {
        self.touchOffset = CGPointZero
    }
    

}