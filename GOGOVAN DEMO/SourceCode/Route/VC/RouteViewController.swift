//
//  RouteViewController.swift
//  GOGOVAN DEMO
//
//  Created by Chuen on 23/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class RouteViewController: UIViewController {
    
    var headerView: RouteHeaderView!
    var historyTableView: UITableView!
    var recommandTableView: UITableView!
    var headerHeight: CGFloat = 100
    var googleSearchViewModal = GoogleSearchViewModal()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        historyTableView = UITableView()
        historyTableView.rx
            .setDelegate(self)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        self.view.addSubview(historyTableView)
        historyTableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view)
        }
//        self.view.addSubview(headerView)
//        headerView.snp.makeConstraints { (make) in
//            make.top.bottom.right.left.equalTo(self.view)
//        }
        
    }
    
    func searchPlaceFromGoogle(place:String) {
        
        var strGoogleApi = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(place)&key=\(publicConstant.googleAPIKey)"
        strGoogleApi = strGoogleApi.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var urlRequest = URLRequest(url: URL(string: strGoogleApi)!)
        urlRequest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, resopnse, error) in
            if error == nil {
                let jsonDict = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                print("json == \(jsonDict)")
            } else {
                //we have error connection google api
            }
        }
        task.resume()
    }

}

extension RouteViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = RouteHeaderView.getRouteHeader()
        let border = UIView(frame: CGRect(x:0, y: headerHeight - 1 , width:self.view.bounds.width, height:1))
        border.backgroundColor = .lightGray
        headerView.addSubview(border)
        
        headerView.pickUpTextField.rx.text
            .orEmpty
            .bind(to: googleSearchViewModal.searchKeyword)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
}
