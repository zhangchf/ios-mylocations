//
//  HudView.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 21/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit

class HudView: UIView {
    
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.frame)
        hudView.isOpaque = false
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.show(animated: animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(x: round((rect.width - boxWidth)/2), y: round((rect.height - boxHeight)/2), width: boxWidth, height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        let hudImage = #imageLiteral(resourceName: "Checkmark")
        let imgPoint = CGPoint(
            x: center.x - hudImage.size.width/2,
            y: center.y - hudImage.size.height/2 - boxHeight/8)
        hudImage.draw(at: imgPoint)
        
        let attribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                       NSForegroundColorAttributeName: UIColor.white ]
        let textSize = text.size(attributes: attribs)
        let textPoint = CGPoint(x: center.x - textSize.width/2, y: center.y - textSize.height/2 + boxHeight/4)
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    func show(animated: Bool) {
        if animated {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//            UIView.animate(withDuration: 0.3, animations: {
//                self.alpha = 1
//                self.transform = CGAffineTransform.identity
//            })
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }

}
