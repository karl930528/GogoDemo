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
    let searchResultList = PublishSubject<[geometricResult]>()
    let searchKeyword = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    init() {
    }
    
}
