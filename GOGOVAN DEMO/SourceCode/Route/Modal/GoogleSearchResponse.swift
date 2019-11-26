//
//  Location.swift
//  GOGOVAN DEMO
//
//  Created by KarlTai on 25/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import Foundation

struct GoogleSearchResponse: Codable {
    var results : [GeometricResult]?
}

class GeometricResult: NSObject, Codable, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(formatted_address, forKey: publicConstant.kformattedAddress)
        coder.encode(geometry, forKey: publicConstant.kGeometry)
        coder.encode(name, forKey: publicConstant.kName)
    }
    
    required init?(coder: NSCoder) {
        formatted_address = coder.decodeObject(forKey: publicConstant.kformattedAddress) as? String
        geometry = coder.decodeObject(forKey: publicConstant.kGeometry) as? Geometry
        name = coder.decodeObject(forKey: publicConstant.kName) as? String
    }
    
    var formatted_address : String?
    var geometry : Geometry?
    var name : String?
}

class Geometry: NSObject, Codable, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(location, forKey: publicConstant.kLocation)
        coder.encode(viewport, forKey: publicConstant.kViewport)
    }
    
    required init?(coder: NSCoder) {
        location = coder.decodeObject(forKey: publicConstant.kLocation) as? Location
        viewport = coder.decodeObject(forKey: publicConstant.kViewport) as? Viewport
    }
    
    var location : Location?
    var viewport : Viewport?
}

class Location: NSObject, Codable, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(lat, forKey: publicConstant.kLat)
        coder.encode(lng, forKey: publicConstant.Klng)
    }
    
    required init?(coder: NSCoder) {
        lat = coder.decodeObject(forKey: publicConstant.kLat) as? Double
        lng = coder.decodeObject(forKey: publicConstant.Klng) as? Double
    }
    
    var lat : Double?
    var lng : Double?
}

class Viewport: NSObject, Codable, NSCoding {
    func encode(with coder: NSCoder) {
        coder.encode(northeast, forKey: publicConstant.KNortheast)
        coder.encode(southwest, forKey: publicConstant.KSouthwest)
    }
    
    required init?(coder: NSCoder) {
        northeast = coder.decodeObject(forKey: publicConstant.KNortheast) as? Location
        southwest = coder.decodeObject(forKey: publicConstant.KSouthwest) as? Location
    }
    
    var northeast : Location?
    var southwest : Location?
}




