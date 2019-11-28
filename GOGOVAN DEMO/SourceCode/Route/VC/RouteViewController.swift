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
    let historyIcon = #imageLiteral(resourceName: "history_icon")
    let headerHeight: CGFloat = 100
    let estimatedHeight: CGFloat = 44
    let googleSearchViewModal = GoogleSearchViewModal()
    
    var headerView: RouteHeaderView!
    var resultTableView: UITableView!
    var historyTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupResultTableView()
        setupHistoryTableView()
        setupTableHeader()
    }
    
    func setupResultTableView() {
        headerView = RouteHeaderView.getRouteHeader()
        resultTableView = UITableView()
        resultTableView.tableFooterView = UIView()
        self.view.addSubview(resultTableView)
        resultTableView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalTo(self.view)
        }
        
        resultTableView.rx
            .setDelegate(self)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        resultTableView.rx.itemSelected
            .subscribe(onNext: { (index) in
                if self.headerView.pickUpTextField.isEditing{
                    guard let result = try? self.googleSearchViewModal.searchResultList.value()[index.row] else { return }
                    self.googleSearchViewModal.handleTap(textField: self.headerView.pickUpTextField,
                                                         result: result,
                                                         index: index.row,
                                                         historyType: .pickup,
                                                         resultType: .searchResult)
                }else{
                    guard let result = try? self.googleSearchViewModal.searchResultList.value()[index.row] else { return }
                    self.googleSearchViewModal.handleTap(textField: self.headerView.dropOffTextField,
                                                         result: result,
                                                         index: index.row,
                                                         historyType: .dropoff,
                                                         resultType: .searchResult)
                }
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        googleSearchViewModal.searchResultList
            .bind(to: self.resultTableView.rx.items) { (tableView, row, element) in
                return self.setupTableCell(result: element, type: .searchResult)
        }
        .disposed(by: googleSearchViewModal.disposeBag)
    }
  
    func setupHistoryTableView() {
        historyTableView = UITableView()
        historyTableView.tableFooterView = UIView()
        self.view.addSubview(historyTableView)
        historyTableView.snp.makeConstraints { (make) in
            make.top.equalTo(resultTableView.snp.top).offset(headerHeight)
            make.bottom.left.right.equalTo(self.view)
        }
        
        let pickupTextFieldTextObservable = headerView.pickUpTextField.rx.text.orEmpty.changed.filter{$0.count == 0}
        let dropoffTextFieldTextObservable = headerView.dropOffTextField.rx.text.orEmpty.changed.filter{$0.count == 0}
        let pickupBeginEditObservable = headerView.pickUpTextField.rx.controlEvent([.editingDidBegin])
        let dropoffBeginEditObservable = headerView.dropOffTextField.rx.controlEvent([.editingDidBegin])
        let pickupEditObservable = headerView.pickUpTextField.rx.controlEvent([.editingChanged])
        let dropoffEditObservable = headerView.dropOffTextField.rx.controlEvent([.editingChanged])
        let pickupEndEditObservable = headerView.pickUpTextField.rx.controlEvent([.editingDidEnd])
        let dropoffEndEditObservable = headerView.dropOffTextField.rx.controlEvent([.editingDidEnd])
        
        historyTableView.rx.itemSelected
            .subscribe(onNext: { (index) in
                if self.headerView.pickUpTextField.isEditing{
                    guard let result = try? self.googleSearchViewModal.recentSearchResultList.value()[index.row] else { return }
                    self.googleSearchViewModal.handleTap(textField: self.headerView.pickUpTextField,
                                                         result: result,
                                                         index: index.row,
                                                         historyType: .pickup,
                                                         resultType: .historyResults)
                }else{
                    guard let result = try? self.googleSearchViewModal.recentSearchResultList.value()[index.row] else { return }
                    self.googleSearchViewModal.handleTap(textField: self.headerView.dropOffTextField,
                                                         result: result,
                                                         index: index.row,
                                                         historyType: .dropoff,
                                                         resultType: .historyResults)
                }
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        googleSearchViewModal.recentSearchResultList
            .bind(to: self.historyTableView.rx.items) { (tableView, row, element) in
                return self.setupTableCell(result: element, type: .historyResults)
        }
        .disposed(by: googleSearchViewModal.disposeBag)
        
        pickupBeginEditObservable
            .subscribe(onNext: { (_) in
                self.headerView.pickUpTextField.backgroundColor = UIColor(hexString: "#C6E0EC", alpha: 0.6)
                self.googleSearchViewModal.recentSearchResultList
                    .onNext(appUserDefaults.recentPickupSearch)
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        dropoffBeginEditObservable
            .subscribe(onNext: { (_) in
                self.headerView.dropOffTextField.backgroundColor = UIColor(hexString: "#C6E0EC", alpha: 0.6)
                self.googleSearchViewModal.recentSearchResultList
                    .onNext(appUserDefaults.recentDropoffSearch)
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        pickupEndEditObservable
            .subscribe(onNext: { (_) in
                self.headerView.pickUpTextField.backgroundColor = UIColor(hexString: "#ECECEC", alpha: 0.6)
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        dropoffEndEditObservable
            .subscribe(onNext: { (_) in
                self.headerView.dropOffTextField.backgroundColor = UIColor(hexString: "#ECECEC", alpha: 0.6)
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        Observable
            .of(pickupBeginEditObservable,dropoffBeginEditObservable)
            .merge()
            .subscribe(onNext: {
                self.googleSearchViewModal.textEdit.onNext(true)
            }).disposed(by: googleSearchViewModal.disposeBag)
        
        Observable
            .of(pickupBeginEditObservable,
                dropoffBeginEditObservable,
                pickupEndEditObservable,
                dropoffEndEditObservable)
            .merge()
            .map { (_) -> Bool in
                return false}
            .bind(to: historyTableView.rx.isHidden)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        Observable
            .of(pickupEditObservable,
                dropoffEditObservable)
            .merge()
            .map { (_) -> Bool in
                return true}
            .bind(to: historyTableView.rx.isHidden)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        pickupTextFieldTextObservable
            .map { (keyword) -> Bool in
                return false}
            .bind(to: historyTableView.rx.isHidden)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        dropoffTextFieldTextObservable
            .map { (keyword) -> Bool in
                return false}
            .bind(to: historyTableView.rx.isHidden)
            .disposed(by: googleSearchViewModal.disposeBag)
    }
    
    func setupTableHeader() {
        let pickupTextFieldTextObservable = headerView.pickUpTextField.rx.text.orEmpty.changed
        let dropoffTextFieldTextObservable = headerView.dropOffTextField.rx.text.orEmpty.changed
        
        pickupTextFieldTextObservable
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: googleSearchViewModal.pickupSearchKeyword)
            .disposed(by: googleSearchViewModal.disposeBag)
        
        dropoffTextFieldTextObservable
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: googleSearchViewModal.dropoffSearchKeyword)
            .disposed(by: googleSearchViewModal.disposeBag)
    }
}

extension RouteViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let border = UIView(frame: CGRect(x:0, y: headerHeight - 1 , width:self.view.bounds.width, height:1))
        border.backgroundColor = .lightGray
        headerView.addSubview(border)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
}

extension RouteViewController {
    func setupTableCell(result:GeometricResult, type:ResultType) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = result.name
        cell.detailTextLabel?.text = result.formatted_address
        cell.detailTextLabel?.textColor = .gray
        cell.selectionStyle = .none
        switch type {
        case .historyResults:
            cell.imageView?.image = historyIcon
            break
        default:
            break
        }
        return cell
    }
}
