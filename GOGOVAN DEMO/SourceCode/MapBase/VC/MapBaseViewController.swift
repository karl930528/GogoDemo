//
//  MapBaseViewController.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 23/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import UIKit
import SnapKit

class MapBaseViewController: AbstractViewController {
    
    var mapContent: MapViewController!
    var mapContainer: UIView!
    var routeContent: RouteViewController!
    var routeContainer: UIView!
    
    lazy var mapContainerHeight: CGFloat = {
        return self.view.frame.height - (isIphoneXSerial() ? 78 + 44 : 44 ) - 100
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar(title: "test")
        self.setupNavBarBtn()
        self.setupUI()
    }
    
    func setupNavBarBtn() {
        let menu_btn = UIBarButtonItem(image: UIImage(named: "menu_btn"), style: .plain, target: self, action: #selector(ggg))
        menu_btn.tintColor = .black
        self.navigationItem.leftBarButtonItem  = menu_btn
    }
    
    @objc func ggg() {
        var frame = self.mapContainer.frame
        frame = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: 0)
        UIView.animate(withDuration: 0.3) {
            self.mapContainer.frame = frame
            self.view.layoutIfNeeded()
        }
    }
    
    func setupUI() {
        setMapView()
        setRouteView()
    }
    
    func setMapView() {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: mapContainerHeight)
        mapContainer = UIView(frame: frame)
        self.view.addSubview(mapContainer)
        
        mapContent = MapViewController()
        mapContainer.addSubview(mapContent.view)
        mapContent.didMove(toParent: self)
        mapContent.view.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(mapContainer)
            make.bottom.equalTo(mapContainer)
            make.left.equalTo(mapContainer)
            make.right.equalTo(mapContainer)
        }
    }
    
    func setRouteView() {
        routeContainer = UIView(frame: CGRect.zero)
        self.view.addSubview(routeContainer)
        routeContainer.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(mapContainer.snp.bottom)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.left.equalTo(self.view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(self.view.safeAreaLayoutGuide.snp.right)
        }
        
        routeContent = RouteViewController()
        routeContent.view.backgroundColor = .white
        routeContainer.addSubview(routeContent.view)
        routeContent.didMove(toParent: self)
        routeContent.view.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(routeContainer)
            make.bottom.equalTo(routeContainer)
            make.left.equalTo(routeContainer)
            make.right.equalTo(routeContainer)
        }
    }
    
}
