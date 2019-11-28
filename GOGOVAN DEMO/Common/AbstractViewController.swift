//
//  AbstractViewController.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 22/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import UIKit

class AbstractViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension AbstractViewController {
    func setupNavigationBar(title: String) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setupNavigationBar(titleView: UIView) {
        self.navigationItem.titleView = titleView
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

