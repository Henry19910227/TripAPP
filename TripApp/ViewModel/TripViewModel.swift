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
    private var disposeBag = DisposeBag()
    
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
    
    func clear() {
        disposeBag = DisposeBag()
    }
}

extension TripViewModel {
    func bindAllTripCellTaps(observables: [Observable<String>]) {
        Observable.merge(observables).subscribe(onNext: { (text) in
            print("按鈕點擊!!! \(text)")
        }).disposed(by: disposeBag)
    }
}

// MARK: API
extension TripViewModel {
    
//    public func apiGetAllTrips() {
//        loadingSubject.onNext(true)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
//            var tripCellTapObservables: [Observable<String>] = []
//            var tripCellVMs: [TripCellViewModel] = []
//            for _ in 0...5 {
//                let item = Trip(title: "test", content: "test", images: "www.bigstockphoto.com/images/homepage/module-6.jpg")
//                let vm = TripCellViewModel(model: item)
//                tripCellVMs.append(vm)
//                if let moreTap = vm.transform(input: nil).moreTab {
//                    tripCellTapObservables.append(moreTap.asObservable())
//                }
//            }
//            self.bindAllTripCellTaps(observables: tripCellTapObservables)
//            self.tripDataSubject.onNext([SectionModel(model: "TripCellViewModel", items: tripCellVMs)])
//            self.loadingSubject.onNext(false)
//        })
//    }
    
    public func apiGetAllTrips() {
        loadingSubject.onNext(true)
        service.apiTrips(parameter: nil).map { [unowned self] (tripItem) -> [SectionModel<String, TripCellViewModel>] in
            var tripCellVMs: [TripCellViewModel] = []
            var tripCellTapObservables: [Observable<String>] = []
            for item in tripItem.data! {
                let vm = TripCellViewModel(model: item)
                tripCellVMs.append(vm)
                if let moreTap = vm.transform(input: nil).moreTab {
                    tripCellTapObservables.append(moreTap.asObservable())
                }
            }
            self.bindAllTripCellTaps(observables: tripCellTapObservables)
            return [SectionModel(model: "TripCellViewModel", items: tripCellVMs)]
        }.subscribe(onSuccess: { [unowned self] (data) in
            self.tripDataSubject.onNext(data)
            self.loadingSubject.onNext(false)
        }, onError: { (error) in
            print("")
        }).disposed(by: disposeBag)
    }
}
