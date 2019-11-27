//
//  GoogleSearchViewModel.swift
//  GOGOVAN DEMO
//
//  Created by KarlTai on 25/11/2019.
//  Copyright © 2019 Chuen. All rights reserved.
//

import Foundation
import RxSwift

class GoogleSearchViewModal {
    let searchResultList = BehaviorSubject<[GeometricResult]>(value:[])
    let recentSearchResultList = BehaviorSubject<[GeometricResult]>(value:[])
    let pickupSearchKeyword = PublishSubject<String>()
    let dropoffSearchKeyword = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    let historyRecondConstant = 5
    
    init() {
       Observable.of(pickupSearchKeyword,dropoffSearchKeyword)
            .merge()
            .subscribe(onNext: { (keyword) in
                let request = MappableRequest<GoogleSearchResponse>(
                    method: .get, releativeURL:"https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(keyword)&key=\(publicConstant.googleAPIKey)",
                    param: nil)
                
                WebServices
                    .requestJSONByModel(request: request)
                    .subscribe(onNext: { (response) in
                        if let results = response.results{
                            self.searchResultList.onNext(results)
                        }
                    }).disposed(by: self.disposeBag)
                
            }).disposed(by: disposeBag)
    }
    
    func updateRecentSearch(result:GeometricResult , type:HistoryType){
        var tempList:[GeometricResult] = type == .pickup ? appUserDefaults.recentPickupSearch : appUserDefaults.recentDropoffSearch
        if tempList.count > 0 && tempList.count < historyRecondConstant{
            tempList.insert(result, at: 0)
        }else if tempList.count >= historyRecondConstant{
            tempList.removeLast()
            tempList.insert(result, at: 0)
        }else{
            tempList.append(result)
        }
        switch type {
        case .pickup:
            appUserDefaults.recentPickupSearch = tempList
            break
        case .dropoff:
            appUserDefaults.recentDropoffSearch = tempList
            break
            
        }
        recentSearchResultList.onNext(tempList)
    }
    
    func replaceText(textField:UITextField, index:Int, type:ResultType) {
        textField.endEditing(true)
        textField.becomeFirstResponder()
        textField.text = ""
        let listSubject = type == .searchResult ? searchResultList : recentSearchResultList
        guard let text = try? listSubject.value()[index].name else { return }
        textField.insertText(text)
    }
    
}
