//
//  AppUserDefault.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 26/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import Foundation

var userDefaults = UserDefaults.standard
var appUserDefaults = AppUserDefaults.init()

struct UserDefaultKey {
    static let recentPickupSearch = "recentPickupSearch"
    static let recentDropoffSearch = "recentDropoffSearch"
}

struct AppUserDefaults {
    func setValue(_ value: Any?, forKey defaultName: String) {
        userDefaults.set(value, forKey: defaultName)
    }
    
    func getValue(forKey defaultName: String) -> Any? {
        return userDefaults.value(forKey: defaultName)
    }
}

