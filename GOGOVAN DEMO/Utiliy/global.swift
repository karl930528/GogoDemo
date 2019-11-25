//
//  UIDevice+Extension.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 24/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import UIKit

class Global:  NSObject {
    
}

struct publicConstant {
    static let googleAPIKey = "AIzaSyCUyh_IxARPpIQfkCuk7udVXCwXGG9hAv8"
}

func isIphoneXSerial() -> Bool {
    if UIScreen.main.nativeBounds.height == 2436 || UIScreen.main.nativeBounds.height == 2688 || UIScreen.main.nativeBounds.height == 1792  {
        return true
    }
    return false
}
