//
//  RouteHeaderView.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 24/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import UIKit
import SnapKit

class RouteHeaderView: UIView {
    
    @IBOutlet weak var pickUpIcon: UIImageView!
    @IBOutlet weak var pickUpTextField: UITextField!
    @IBOutlet weak var dropOffIcon: UIImageView!
    @IBOutlet weak var dropOffTextField: UITextField!

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    class func getRouteHeader() -> RouteHeaderView {
        let view = UINib(nibName: "RouteHeaderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RouteHeaderView
        return view
    }
    
}
