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
    let searchResultList = PublishSubject<[GeometricResult]>()
//      let pickupSearchResultList = PublishSubject<[GeometricResult]>()
    let recentSearchResultList = PublishSubject<[GeometricResult]>()
    let pickupSearchKeyword = PublishSubject<String>()
    let dropoffSearchKeyword = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    let historyRecondConstant = 5
    
    init() {
        Observable
            .of(pickupSearchKeyword,dropoffSearchKeyword)
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
    
    func updatePickupRecentSearch(result:GeometricResult){
        var tempList:[GeometricResult] = appUserDefaults.recentPickupSearch
        if tempList.count > 0 && tempList.count < historyRecondConstant{
            tempList.insert(result, at: 0)
        }else if tempList.count >= historyRecondConstant{
            tempList.removeLast()
            tempList.insert(result, at: 0)
        }else{
            tempList.append(result)
        }
        appUserDefaults.recentPickupSearch = tempList
        recentSearchResultList.onNext(appUserDefaults.recentPickupSearch)
    }
    
    func updateDropoffRecentSearch(result:GeometricResult){
        var tempList:[GeometricResult] = appUserDefaults.recentDropoffSearch
        if tempList.count > 0 && tempList.count < historyRecondConstant{
            tempList.insert(result, at: 0)
        }else if tempList.count >= historyRecondConstant{
            tempList.removeLast()
            tempList.insert(result, at: 0)
        }else{
            tempList.append(result)
        }
        appUserDefaults.recentDropoffSearch = tempList
        recentSearchResultList.onNext(appUserDefaults.recentDropoffSearch)
    }
    
}
