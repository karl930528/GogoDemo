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
    var routeContent: RouteViewController!
    var mapContainer: UIView!
    var routeContainer: UIView!
    let menuIcon = #imageLiteral(resourceName: "menu_btn")
    let backIcon = #imageLiteral(resourceName: "back_btn")
    
    var menu_btn: UIBarButtonItem!
    var back_btn: UIBarButtonItem!
    
    lazy var mapContainerHeight: CGFloat = {
        return self.view.frame.height - (isIphoneXSerial() ? 78 + 44 : 64 ) - 100
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar(title: "Gogovan")
        setupNavBarBtn()
        setupUI()
    }
    
    func setupNavBarBtn() {
        menu_btn = UIBarButtonItem(image: menuIcon,
                                       style: .plain,
                                       target: self,
                                       action: nil)
        
        back_btn = UIBarButtonItem(image: backIcon,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickBack))
        
        menu_btn.tintColor = .black
        back_btn.tintColor = .black
        self.navigationItem.leftBarButtonItem  = menu_btn
    }
    
    func setupUI() {
        setMapView()
        setRouteView()
    }
    
    func setMapView() {
        let frame = CGRect(x: 0,
                           y: 0,
                           width: self.view.frame.size.width,
                           height: mapContainerHeight)
        mapContainer = UIView(frame: frame)
        self.view.addSubview(mapContainer)
        
        mapContent = MapViewController()
        mapContainer.addSubview(mapContent.view)
        mapContent.didMove(toParent: self)
        mapContent.view.snp.makeConstraints { (make) -> Void in
            make.top.bottom.left.right.equalTo(mapContainer)
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
            make.top.bottom.left.right.equalTo(routeContainer)
        }
        mapContent.googleSearchViewModal = routeContent.googleSearchViewModal
        mapContent.setupMapView()
        
        routeContent.googleSearchViewModal.textEdit
            .subscribe(onNext: { (isEdit) in
                self.slide(isEdit: isEdit)
            }).disposed(by: routeContent.googleSearchViewModal.disposeBag)
    }
    
}

extension MapBaseViewController {
    @objc func clickBack() {
        routeContent.googleSearchViewModal.textEdit.onNext(false)
    }
    
    func slide(isEdit:Bool) {
        var frame = self.mapContainer.frame
        frame = CGRect(x: frame.minX,
                       y: frame.minY,
                       width: frame.width,
                       height: isEdit ? 0 : mapContainerHeight)
        UIView.animate(withDuration: 0.3) {
            self.mapContainer.frame = frame
            self.navigationItem.leftBarButtonItem = isEdit ? self.back_btn : self.menu_btn
            self.view.layoutIfNeeded()
            if !isEdit{
                self.view.endEditing(true)
            }
        }
    }
}
