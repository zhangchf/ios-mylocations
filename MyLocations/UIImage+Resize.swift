//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 28/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import UIKit

extension UIImage {

    func resizedImage(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = max(horizontalRatio, verticalRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
