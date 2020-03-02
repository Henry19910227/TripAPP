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

class TripViewModel: ViewModelProtocol {
    
    typealias Input = TripInput
    typealias Output = TripOutput
    
    struct TripInput {
        public var infoTab: Signal<Void>
        init(infoTab: Signal<Void> = PublishSubject<Void>().asSignal(onErrorJustReturn: ())) {
            self.infoTab = infoTab
        }
    }
    
    struct TripOutput {
        public var tripCellVMs: Driver<[SectionModel<String, TripCellViewModel>]>?
        public var loading: Driver<Bool>?
        init(tripCellVMs: Driver<[SectionModel<String, TripCellViewModel>]>,
             loading: Driver<Bool>) {
            self.tripCellVMs = tripCellVMs
            self.loading = loading
        }
    }
    
    // RX
    private let disposeBag = DisposeBag()
    
    // API
    public var service: TripService
    
    // Subject
    private let tripDataSubject = PublishSubject<[SectionModel<String, TripCellViewModel>]>()
    private let loadingSubject = PublishSubject<Bool>()
    private let infoSubject = PublishSubject<String>()
    
    private var input: Input?
    
    init(service: TripService) {
        self.service = service
    }
    
    func transform(input: Input?) -> Output {
        self.input = input
        return Output(tripCellVMs: tripDataSubject.asDriver(onErrorJustReturn: []),
                      loading: loadingSubject.asDriver(onErrorJustReturn: false))
    }
}

extension TripViewModel {

}

// MARK: API
extension TripViewModel {
    public func apiGetAllTrips() {
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
