//
//  Utils.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 20/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import Foundation
import CoreLocation

class Utils {
    
    class func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s
        }
        
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        return line1 + "\n" + line2
    }

}
