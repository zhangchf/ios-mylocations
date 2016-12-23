//
//  Functions.swift
//  MyLocations
//
//  Created by Chaofan Zhang on 21/12/2016.
//  Copyright © 2016 Chaofan Zhang. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}
