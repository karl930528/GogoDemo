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

class MapViewController: AbstractViewController { 
    let zoomScale: Float = 17.0
    let strokeWidth: CGFloat = 8.0
    let pickupIcon = #imageLiteral(resourceName: "pickup_icon")
    let dropoffIcon = #imageLiteral(resourceName: "dropoff_icon")
    let dotIcon = #imageLiteral(resourceName: "dot_icon")
    
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
                guard let _:Double = location.lat, let _:Double = location.lng else {
                    self.markerLocation.pickupLocation = nil
                    self.setupMaker()
                    return
                }
                if (!self.isLocationFree(location: location, type:.pickupPoint)) { return }
                self.markerLocation.pickupLocation = location
                self.setupMaker()
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        googleSearchViewModal.dropoffLocation
            .skip(1)
            .subscribe(onNext: { (location) in
                guard let _ = location.lat, let _ = location.lng else {
                    self.markerLocation.dropoffLocation = nil
                    self.setupMaker()
                    return
                }
                if (!self.isLocationFree(location: location, type:.dropoffPoint)) { return }
                self.markerLocation.dropoffLocation = location
                self.setupMaker()
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        googleSearchViewModal.directionPath
            .subscribe(onNext: { (pathString) in
                self.drawPath(from: pathString)
            }).disposed(by: googleSearchViewModal.disposeBag)
    }
    
    func setupMaker() {
        vMap.clear()
        if markerLocation.pickupLocation != nil{
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: markerLocation.pickupLocation?.lat ?? 0,
                                                                    longitude: markerLocation.pickupLocation?.lng ?? 0))
            marker.map = vMap
//            marker.icon = pickupIcon.resized(to: CGSize(width: 30, height: 30))
        }
        if markerLocation.dropoffLocation != nil{
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: markerLocation.dropoffLocation?.lat ?? 0,
                                                                    longitude: markerLocation.dropoffLocation?.lng ?? 0))
            marker.map = vMap
//            marker.icon = dropoffIcon.resized(to: CGSize(width: 20, height: 20))
        }
        if (markerLocation.pickupLocation != nil) && (markerLocation.dropoffLocation != nil) {
            googleSearchViewModal.routeLocation.onNext(markerLocation)
            googleSearchViewModal.textEdit.onNext(false)
        }
    }
}

extension MapViewController {
    func locationPermission(){
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func isLocationFree(location: Location, type:MarkerType) -> Bool {
        guard let marker = type == .pickupPoint ? markerLocation.pickupLocation : markerLocation.dropoffLocation else {
            if type == .pickupPoint{
                markerLocation.pickupLocation = location
            }else{
                markerLocation.dropoffLocation = location
            }
            return true
        }
        return marker.lat != location.lat && marker.lng != location.lng
    }
    
    func drawPath(from polyStr: String){
        let paths = GMSPath(fromEncodedPath: polyStr)
        let polyLine = GMSPolyline(path: paths)
        polyLine.strokeWidth = strokeWidth
        polyLine.strokeColor = .lightGray
        let styles: [GMSStrokeStyle] = [GMSStrokeStyle.solidColor(UIColor(patternImage: dotIcon)), GMSStrokeStyle.solidColor(.gray)]
        let scale = 1.0 / vMap.projection.points(forMeters: 1, at: vMap.camera.target)
        let solidLine = NSNumber(value: Float(strokeWidth) * Float(scale))
        let gap = NSNumber(value: Float(strokeWidth) * Float(scale))
        let span = GMSStyleSpans(polyLine.path!, styles, [solidLine, gap], GMSLengthKind.rhumb)
        polyLine.spans = span
        polyLine.map = vMap
    }
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
