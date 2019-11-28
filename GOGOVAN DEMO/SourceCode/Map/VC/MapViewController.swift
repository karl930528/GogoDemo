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
import RxSwift

struct PickDropLocation {
    var pickupLocation: Location?
    var dropoffLocation: Location?
}

class MapViewController: AbstractViewController { 
    
    let zoomScale: Float = 18.0
    let pickupIcon = #imageLiteral(resourceName: "pickup_icon")
    let dropoffIcon = #imageLiteral(resourceName: "dropoff_icon")
    
    var vMap: GMSMapView!
    var currentLocation: CLLocation?
    var locationManager = CLLocationManager()
    var googleSearchViewModal: GoogleSearchViewModal!
    var markerLocation: PickDropLocation = PickDropLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    } 
    
    func setupMapView() {
        locationPermission()
        setupGoogleMap()
    }
    
    func locationPermission(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupGoogleMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 22.312108,
                                              longitude: 114.221616,
                                              zoom: zoomScale)
        
        vMap = GMSMapView.map(withFrame: .zero, camera: camera)
        vMap.delegate = self
        
        locationManager.startUpdatingLocation()
        vMap.isMyLocationEnabled = true
        vMap.settings.myLocationButton = true
        
        self.view.addSubview(vMap)
        self.view.sendSubviewToBack(vMap)
        vMap.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(self.view.safeAreaInsets.top)
            make.bottom.equalTo(self.view.safeAreaInsets.bottom)
            make.left.equalTo(self.view.safeAreaInsets.left)
            make.right.equalTo(self.view.safeAreaInsets.right)
        }
        
        googleSearchViewModal.pickupLocation
            .skip(1)
            .subscribe(onNext: { (location) in
                guard let lat:Double = location.lat, let lng:Double = location.lng else { return }
                self.markerLocation.pickupLocation = location
                self.setupMaker(lat: lat, lng: lng, type: .pickupPoint)
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        googleSearchViewModal.dropoffLocation
            .skip(1)
            .subscribe(onNext: { (location) in
                guard let lat = location.lat, let lng = location.lng else { return }
                self.setupMaker(lat: lat, lng: lng, type: .dropoffPoint)
            }).disposed(by: googleSearchViewModal.disposeBag)
    }
    
    func setupMaker(lat:Double, lng:Double, type: MarkerType) {
//        let location = Location(lat: lat, lng: lng)
//        if !isLocationFree(location: location){
//            return
//        }
        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: lat, longitude: lng))
        marker.map = vMap
//        marker.userData = Location
//        allMarkerLocation.append(location)
        
        switch type {
        case .pickupPoint:
            marker.icon = pickupIcon.resized(to: CGSize(width: 20, height: 20))
            break
        case .dropoffPoint:
            marker.icon = dropoffIcon.resized(to: CGSize(width: 20, height: 20))
            break
        }
    }
    
//    func isLocationFree(location: Location) -> Bool {
//        var isFree: Bool = true
//        for markerLocation in allMarkerLocation{
//            isFree = markerLocation.lat != location.lat && markerLocation.lng != location.lng
//        }
//        return isFree
//    }
}

extension MapViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return true
    }
}

extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        currentLocation = location
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!,
                                              longitude: (location?.coordinate.longitude)!,
                                              zoom: zoomScale)
        self.vMap.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
}
