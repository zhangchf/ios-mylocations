//
//  String+AddText.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 28/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import Foundation

extension String {
    
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
