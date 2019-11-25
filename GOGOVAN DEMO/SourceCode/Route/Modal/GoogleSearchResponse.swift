//
//  Location.swift
//  GOGOVAN DEMO
//
//  Created by KarlTai on 25/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import Foundation

struct GoogleSearchResponse: Codable {
    var results : [geometricResult]?
}

struct geometricResult: Codable {
    var formatted_address : String?
    var geometry : Geometry?
    var name : String?
}

struct Geometry: Codable {
    var location : Location?
    var viewport : Viewport?
}

struct Location: Codable {
    var lat : Double?
    var lng : Double?
}

struct Viewport: Codable {
    var northeast : Location?
    var southwest : Location?
}




