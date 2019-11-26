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
    var historyTableView: UITableView!
    var googleSearchViewModal = GoogleSearchViewModal()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableHeader()
    }
    
    func setupUI() {
        resultTableView = UITableView()
        resultTableView.tableFooterView = UIView()
        self.view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view)
        }
        
        historyTableView = UITableView()
        historyTableView.tableFooterView = UIView()
        historyTableView.frame = resultTableView.frame
        self.view.addSubview(historyTableView)
        
        resultTableView.rx
            .setDelegate(self)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        Observable
            .combineLatest(googleSearchViewModal.searchResultList,
                           resultTableView.rx.itemSelected)
            .subscribe(onNext: { (results,index) in
                if results.count  > 0 {
                    self.googleSearchViewModal.updatePickupRecentSearch(result: results[index.row] )
                }
            }, onError: { (error) in
                
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        //        Observable
        //            .combineLatest(googleSearchViewModal.searchResultList,
        //                           googleSearchViewModal.recentSearchResultList,
        //                           googleSearchViewModal.pickupBeginEdit)
        //            .map({ (list:[GeometricResult], recentList:[GeometricResult] , isEditing: Bool) -> Array<(GeometricResult, Bool)> in
        //                var arr = Array<(GeometricResult, Bool)>()
        //                for result in list{
        //                    arr.append((result,isEditing))
        //                }
        //
        //                for result in recentList{
        //                    arr.append((result,isEditing))
        //                }
        //                return arr
        //            })
        googleSearchViewModal.searchResultList
            .bind(to: self.resultTableView.rx.items) { (tableView, row, element) in
                let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: nil)
                cell.textLabel?.text = element.name
                cell.detailTextLabel?.text = element.formatted_address
                cell.detailTextLabel?.textColor = .gray
                cell.selectionStyle = .none
                return cell
        }
        .disposed(by: googleSearchViewModal.disposeBag)
        
    }
    
    func setupTableHeader() {
        
        let pickupTextFieldTextObservable = headerView.pickUpTextField.rx.text.orEmpty.changed
        let dropoffTextFieldTextObservable = headerView.dropOffTextField.rx.text.orEmpty.changed
        let pickupEditObservable = headerView.pickUpTextField.rx.controlEvent([.editingChanged])
        let dropoffEditObservable = headerView.pickUpTextField.rx.controlEvent([.editingChanged])
        Observable
            .zip(pickupTextFieldTextObservable, pickupEditObservable)
            .asObservable()
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map { (key) -> String in
                return key.0}
            .bind(to: googleSearchViewModal.pickupSearchKeyword)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        Observable
            .zip(dropoffTextFieldTextObservable, dropoffEditObservable)
            .asObservable()
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .map { (key) -> String in
                return key.0}
            .bind(to: googleSearchViewModal.dropoffSearchKeyword)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        headerView.pickUpTextField.rx
            .controlEvent([.editingChanged,.editingDidEnd])
            .asObservable()
            .subscribe(onNext: { _ in
                self.googleSearchViewModal.pickupBeginEdit.onNext(false)
            })
            .disposed(by: googleSearchViewModal.disposeBag)
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
        
        return headerView
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
}
