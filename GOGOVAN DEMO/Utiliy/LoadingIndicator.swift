//
//  LoadingIndicator.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 24/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import Foundation
import KRProgressHUD

class LoadingIndicator {
    
    private static var hudCounter = 0 {
        didSet {
            debugPrint(LoadingIndicator.hudCounter)
        }
    }
    
    static func show() {
        LoadingIndicator.hudCounter += 1
        if LoadingIndicator.hudCounter > 0 {
            KRProgressHUD.set(style: .black)
            KRProgressHUD.set(maskType: .black)
            KRProgressHUD.showOn(UIApplication.shared.keyWindow!.rootViewController!).show()
        }
    }
    
    static func hide() {
        LoadingIndicator.hudCounter -= 1
        if LoadingIndicator.hudCounter <= 0 {
            KRProgressHUD.dismiss()
        }
    }
}
