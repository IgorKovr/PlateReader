//
//  PlaybackView.swift
//  PlateReader
//
//  Created by Igor Kovryzhkin on 6/16/17.
//  Copyright © 2017 Igor Kovryzhkin. All rights reserved.
//

import UIKit
import Vision
import QuartzCore

fileprivate let rectLineWidth: CGFloat = 2.0

class VideoOverlayView: UIView {
    var drawingRects: [VNRectangleObservation] = []
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        UIGraphicsPushContext(context)
        context.setStrokeColor(UIColor.green.cgColor)
        context.setLineWidth(rectLineWidth)
        
        let plusPath = UIBezierPath()
        plusPath.lineWidth = 2.0
        for rect in drawingRects {
            plusPath.move(to: absolutePoint(rect.topLeft))
            plusPath.addLine(to: absolutePoint(rect.topRight))
            plusPath.addLine(to: absolutePoint(rect.bottomRight))
            plusPath.addLine(to: absolutePoint(rect.bottomLeft))
            plusPath.addLine(to: absolutePoint(rect.topLeft))
        }
        plusPath.stroke()
    }
}

extension UIView {
    func absolutePoint(_ relativePoint: CGPoint) -> CGPoint {
        let w = self.frame.size.width
        let h = self.frame.size.height
        let point = CGPoint(x: relativePoint.y * w, y: relativePoint.x * h)
        return point
    }
    
}

