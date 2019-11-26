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
    let recentSearchResultList = PublishSubject<[GeometricResult]>()
    let pickupSearchKeyword = PublishSubject<String>()
    let dropoffSearchKeyword = PublishSubject<String>()
    let pickupBeginEdit = PublishSubject<Bool>()
    let disposeBag = DisposeBag()
    
    init() {
        Observable
            .of(pickupSearchKeyword,dropoffSearchKeyword)
            .merge()
            .subscribe(onNext: { (keyword) in
                let request = MappableRequest<GoogleSearchResponse>(method: .get, releativeURL:"https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(keyword)&key=\(publicConstant.googleAPIKey)", param: nil )
                
                WebServices
                    .requestJSONByModel(request: request)
                    .subscribe(onNext: { (response) in
                        if let results = response.results{
                            self.searchResultList.onNext(results)
                        }
                    }).disposed(by: self.disposeBag)
                
            }, onError: { (error) in
                
            }).disposed(by: disposeBag)
        
        pickupBeginEdit
            .asObservable()
            .subscribe(onNext: { (beginEdit) in
                beginEdit ?
                    self.recentSearchResultList.onNext(appUserDefaults.recentPickupSearch) :
                    self.recentSearchResultList.onNext([])
            }, onError: { (error) in
                
            }).disposed(by: disposeBag)
        
    }
    
    func updatePickupRecentSearch(result:GeometricResult){
        var tempList:[GeometricResult] = []
        
        tempList = appUserDefaults.recentPickupSearch
        if tempList.count > 0 && tempList.count < 5{
            tempList.insert(result, at: 0)
        }else if tempList.count >= 5{
            tempList.removeLast()
            tempList.insert(result, at: 0)
        }else{
            tempList.append(result)
        }
        appUserDefaults.recentPickupSearch = tempList
    }
    
}
