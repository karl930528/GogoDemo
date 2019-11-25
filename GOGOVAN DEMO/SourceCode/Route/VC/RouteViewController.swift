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
    
    let headerHeight: CGFloat = 100
    let estimatedHeight: CGFloat = 44
    
    var headerView: RouteHeaderView!
    var resultTableView: UITableView!
    var googleSearchViewModal = GoogleSearchViewModal()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        resultTableView = UITableView()
        resultTableView.tableFooterView = UIView()
        resultTableView.rx
            .setDelegate(self)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        Observable
            .combineLatest(googleSearchViewModal.searchResultList,resultTableView.rx.itemSelected)
            .subscribe(onNext: { (results,index) in
                
            }, onError: { (error) in
                
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        Observable
            .combineLatest(googleSearchViewModal.searchResultList,googleSearchViewModal.recentSearchResultList,googleSearchViewModal.pickupBeginEdit)
            .map({ (list:[geometricResult], recentList:[geometricResult] , isEditing: Bool) -> Array<(geometricResult, Bool)> in
                var arr = Array<(geometricResult, Bool)>()
                for result in list{
                    arr.append((result,isEditing))
                }
                
                for result in recentList{
                    arr.append((result,isEditing))
                }
                return arr
            })
            .bind(to: self.resultTableView.rx.items) { (tableView, row, element) in
                let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = element.0.name
                cell.detailTextLabel?.text = element.0.formatted_address
                cell.detailTextLabel?.textColor = .gray
                cell.selectionStyle = .none
                return cell
            }.disposed(by: googleSearchViewModal.disposeBag)
        
        self.view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view)
        }
    }

}

extension RouteViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return estimatedHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerView = RouteHeaderView.getRouteHeader()
        let border = UIView(frame: CGRect(x:0, y: headerHeight - 1 , width:self.view.bounds.width, height:1))
        border.backgroundColor = .lightGray
        headerView.addSubview(border)
        
        headerView.pickUpTextField.rx.text
            .orEmpty
            .skip(1)
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
//            .filter{ $0.count != 0 }
            .bind(to: googleSearchViewModal.pickupSearchKeyword)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        headerView.pickUpTextField.rx.controlEvent([.editingDidBegin])
            .asObservable()
            .subscribe(onNext: { _ in
                self.googleSearchViewModal.pickupBeginEdit.onNext(true)
            })
            .disposed(by: googleSearchViewModal.disposeBag)
        
        headerView.pickUpTextField.rx.controlEvent([.editingChanged,.editingDidEnd])
            .asObservable()
            .subscribe(onNext: { _ in
                self.googleSearchViewModal.pickupBeginEdit.onNext(false)
            })
            .disposed(by: googleSearchViewModal.disposeBag)
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
}
