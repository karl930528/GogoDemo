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
    static let kformattedAddress = "kformattedAddress"
    static let kGeometry = "kGeometry"
    static let kName = "kName"
    static let kLocation = "kLocation"
    static let kViewport = "KViewport"
    static let kLat = "kLat"
    static let Klng = "kLng"
    static let KNortheast = "KNortheast"
    static let KSouthwest = "KSouthwest"
}

func isIphoneXSerial() -> Bool {
    if UIScreen.main.nativeBounds.height == 2436 || UIScreen.main.nativeBounds.height == 2688 || UIScreen.main.nativeBounds.height == 1792  {
        return true
    }
    return false
}
