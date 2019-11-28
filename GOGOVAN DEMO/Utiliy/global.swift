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

struct urlPath {
    static let googleSearchPath = "https://maps.googleapis.com/maps/api/place/textsearch/json"
    static let googleDirectionPath = "https://maps.googleapis.com/maps/api/directions/json"
}

func isIphoneXSerial() -> Bool {
    if (UIScreen.main.nativeBounds.height == 2436 ||
        UIScreen.main.nativeBounds.height == 2688 ||
        UIScreen.main.nativeBounds.height == 1792 )
    {
        return true
    }
    return false
}

//func handleOptional<M>(optionalObject: M?) -> M {
//
//    guard let nonOptionalObject = optionalObject else { return ValueContainer(value: M) }
//    return nonOptionalObject
//}
//
//protocol ValueType {
//    init?(raw: AnyObject)
//}
//
//struct ValueContainer<T: ValueType> {
//    var value: T
//
//    init(value: T) {
//        self.value = value
//    }
//
//    init?(raw: AnyObject) {
//        guard let value = T(raw: raw) else { return nil }
//        self.init(value: value)
//    }
//}
//
