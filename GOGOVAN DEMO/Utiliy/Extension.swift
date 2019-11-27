//
//  Extension.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 24/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import Foundation
import RxSwift

extension UIApplication {
    
    public class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}

extension Observable{
    func showLoadingDialog() -> Observable<Element> {
        return self.do(onSubscribed: {
            LoadingIndicator.show()
        }, onDispose: {
            LoadingIndicator.hide()
        })
    }
    
    func showErrorAlert() -> Observable<Element> {
        return self.do(onError: { (error) in
            UIApplication.topViewController()?.showAlert(title: "Error", message: error.localizedDescription, completionHandler: { (_) in
                
            })
        })
    }
}

extension UIViewController {
    func showAlert(title:String?, message:String, btnTitle: String? = "OK", completionHandler: @escaping ((Bool)->Void)) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let button = btnTitle {
            alert.addAction(UIAlertAction(title: button, style: .cancel, handler: { (_) -> Void in
                completionHandler(true)
            }))
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension AppUserDefaults {
    
    var recentPickupSearch: [GeometricResult] {
        get {
            let data = userDefaults.object(forKey: UserDefaultKey.recentPickupSearch) as? Data
            guard let d = data else { return [] }
            return NSKeyedUnarchiver.unarchiveObject(with: d) as! [GeometricResult]
        }
        
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            userDefaults.set(data, forKey: UserDefaultKey.recentPickupSearch)
        }
    }
    
    var recentDropoffSearch: [GeometricResult] {
        get {
            let data = userDefaults.object(forKey: UserDefaultKey.recentDropoffSearch) as? Data
            guard let d = data else { return [] }
            return NSKeyedUnarchiver.unarchiveObject(with: d) as! [GeometricResult]
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            userDefaults.set(data, forKey: UserDefaultKey.recentDropoffSearch)
        }
    }
}
