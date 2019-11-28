//
//  GoogleDirectionResponse.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 28/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import Foundation

struct GoogleDirectionResponse : Codable {
    var routes: [Route]?
}

struct Route : Codable {
    var bounds: Bounds?
    var overview_polyline: Polyline?
    var summary: String?
    
}

class Bounds : Viewport{
}

//struct directionLocation : V {
//    var lat: String?
//    var lng: String?
//}

struct Polyline : Codable {
    var points: String?
}
