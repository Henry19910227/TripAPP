//
//  TripViewModel.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class TripViewModel {
    
    // RX
    private let disposeBag = DisposeBag()
    
    // API
    public var service: TripService
    
    // Output
    public var tripCellVMs: Driver<[SectionModel<String, TripCellViewModel>]>?
    public var loading: Driver<Bool>?
    
    // Subject
    private let tripDataSubject = PublishSubject<[SectionModel<String, TripCellViewModel>]>()
    private let loadingSubject = PublishSubject<Bool>()
    
    
    init(service: TripService) {
        self.service = service
        self.transform()
    }
}

extension TripViewModel {
    private func transform() {
        tripCellVMs = tripDataSubject.asDriver(onErrorJustReturn: [])
        loading = loadingSubject.asDriver(onErrorJustReturn: false)
    }
}

extension TripViewModel {
    
    func apiGetAllTrips() {
        loadingSubject.onNext(true)
        service.apiTrips(parameter: nil).map { (tripItem) -> [SectionModel<String, TripCellViewModel>] in
            var tripCellVMs: [TripCellViewModel] = []
            for item in tripItem.data! {
                let vm = TripCellViewModel()
                vm.model = item
                tripCellVMs.append(vm)
            }
            return [SectionModel(model: "TripCellViewModel", items: tripCellVMs)]
        }.subscribe(onSuccess: { [unowned self] (data) in
            self.tripDataSubject.onNext(data)
            self.loadingSubject.onNext(false)
        }, onError: { (error) in
            print("")
        }).disposed(by: disposeBag)
    }
}
