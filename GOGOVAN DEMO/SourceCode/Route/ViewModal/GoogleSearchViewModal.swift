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
    let pickupLocation = BehaviorSubject<Location>(value: Location())
    let dropoffLocation = BehaviorSubject<Location>(value: Location())
    let routeLocation = PublishSubject<PickDropLocation>()
    let directionPath = PublishSubject<String>()
    let textEdit = PublishSubject<Bool>()
    let disposeBag = DisposeBag()
    
    let historyRecondConstant = 5
    
    init() {
       pickupSearchKeyword
            .subscribe(onNext: { (keyword) in
                if keyword.count == 0{
                    self.searchResultList.onNext([])
                    self.pickupLocation.onNext(Location())
                    return
                }
                self.googleSearchPlace(keyword: keyword)
            }).disposed(by: disposeBag)
        
        dropoffSearchKeyword
            .subscribe(onNext: { (keyword) in
                if keyword.count == 0{
                    self.searchResultList.onNext([])
                    self.dropoffLocation.onNext(Location())
                    return
                }
                self.googleSearchPlace(keyword: keyword)
            }).disposed(by: disposeBag)
    
        routeLocation
            .subscribe(onNext: { (pickdropLocation) in
                self.googleSearchDirection(pickdropLocation: pickdropLocation)
            }).disposed(by: disposeBag)
    }
    
    func googleSearchPlace(keyword:String) {
        let request = MappableRequest<GoogleSearchResponse>(
            method: .get, releativeURL:"\(urlPath.googleSearchPath)?query=\(keyword)&key=\(publicConstant.googleAPIKey)",
            param: nil)
        WebServices
            .requestJSONByModel(request: request)
            .subscribe(onNext: { (response) in
                if let results = response.results{
                    self.searchResultList.onNext(results)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func googleSearchDirection(pickdropLocation:PickDropLocation){
        guard let pickLat = pickdropLocation.pickupLocation?.lat, let pickLng = pickdropLocation.pickupLocation?.lng,
              let dropLat = pickdropLocation.dropoffLocation?.lat, let dropLng = pickdropLocation.dropoffLocation?.lng else {
           return
        }
        let request = MappableRequest<GoogleDirectionResponse>(
            method: .get, releativeURL:"\(urlPath.googleDirectionPath)?origin=\(pickLat),\(pickLng)&destination=\(dropLat),\(dropLng)&sensor=false&mode=driving&key=\(publicConstant.googleAPIKey)",
            param: nil)
        WebServices
            .requestJSONByModel(request: request)
            .subscribe(onNext: { (response) in
                if let routes = response.routes{
                    self.directionPath.onNext(routes.first?.overview_polyline?.points ?? "")
                }
            }).disposed(by: self.disposeBag)

    }
}

extension GoogleSearchViewModal{
    func handleTap(textField:UITextField, result:GeometricResult, index:Int, historyType:HistoryType, resultType:ResultType){
        replaceText(textField: textField,
                    index: updateRecentSearch(result: result, type: historyType, index: index),
                    type: resultType)
        historyType == .pickup ? pickupLocation.onNext(result.geometry?.location ?? Location()) :
            dropoffLocation.onNext(result.geometry?.location ?? Location())
    }
    
    func updateRecentSearch(result:GeometricResult, type:HistoryType, index:Int) -> Int{
        var resultIndex:Int = index
        var tempList:[GeometricResult] = type == .pickup ? appUserDefaults.recentPickupSearch : appUserDefaults.recentDropoffSearch
        
        for i in 0..<tempList.count{
            if tempList[i].formatted_address == result.formatted_address {
                tempList.remove(at: i)
                resultIndex = 0
                break
            }
        }
        
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
        return resultIndex
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
