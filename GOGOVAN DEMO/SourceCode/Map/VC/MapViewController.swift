//
//  MapViewController.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 23/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import UIKit
import GoogleMaps
import SnapKit

class MapViewController: AbstractViewController {
    
    let zoomScale:Float = 16.0
    var vMap: GMSMapView!
    var currentLocation: CLLocation?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGoogleMap()
    }
    
    func setupGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 22.312108,
                                              longitude: 114.221616,
                                              zoom: zoomScale)
        
        vMap = GMSMapView.map(withFrame: .zero, camera: camera)
        vMap.delegate = self
        
        locationManager.startUpdatingLocation()
        vMap.isMyLocationEnabled = true
        
        self.view.addSubview(vMap)
        self.view.sendSubviewToBack(vMap)
        vMap.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.safeAreaInsets.top)
            make.bottom.equalTo(self.view.safeAreaInsets.bottom)
            make.left.equalTo(self.view.safeAreaInsets.left)
            make.right.equalTo(self.view.safeAreaInsets.right)
        }
        
    }
}

extension MapViewController : GMSMapViewDelegate {
    
}
