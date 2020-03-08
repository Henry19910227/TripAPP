//
//  TripCellViewMocel.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class TripCellViewModel: ViewModelProtocol {
    
    var disposeBag = DisposeBag()
    
    typealias Input = TripCellInput
    typealias Output = TripCellOutput
    
    struct TripCellInput {
        public var moreTab: Signal<Void>
        init(moreTab: Signal<Void> = PublishSubject<Void>().asSignal(onErrorJustReturn: ())) {
            self.moreTab = moreTab
        }
    }
    
    struct TripCellOutput {
        public var moreTab: Signal<String>?
        public var title: Observable<String>?
        public var content: Observable<String>?
        public var images: Observable<[SectionModel<String, String>]>?
        init(moreTab: Signal<String>?,
             title: Observable<String>?,
             content: Observable<String>?,
             images: Observable<[SectionModel<String, String>]>?) {
             self.moreTab = moreTab
             self.title = title
             self.content = content
             self.images = images
        }
    }
    
    public var model: Trip?
    private var input: Input?
    private var titleObservable: Observable<String>?
    private var contentObservable: Observable<String>?
    private var imagesObservable: Observable<[SectionModel<String, String>]>?
    private var tapSubject = PublishSubject<String>()
    
    init(model: Trip?) {
        self.model = model
        bindModel()
    }
    
    public func clear() {
        disposeBag = DisposeBag()
    }
}

extension TripCellViewModel {
    public func transform(input: Input?) -> Output {
        self.input = input
        setupTapSignal()
        return Output(moreTab: tapSubject.asSignal(onErrorJustReturn: ""),
                      title: titleObservable,
                      content: contentObservable,
                      images: imagesObservable)
    }
}

// MARK: - Bind
extension TripCellViewModel {
    private func bindModel() {
        titleObservable = Observable.just(model!.title)
        contentObservable = Observable.just(model!.content)
        imagesObservable = Observable.just(model!.images).map({ (imageStr) -> [SectionModel<String, String>] in
            let imgs = imageStr.components(separatedBy: "http://")
            let result = imgs.filter { (img) -> Bool in
                return img.hasSuffix(".jpg") || img.hasSuffix(".JPG")
            }.map { (img) -> String in
                return "https://\(img)"
            }
            return [SectionModel(model: "TripImage", items: result)]
        })
    }
    
    private func setupTapSignal() {
        input?.moreTab.emit(onNext:  { [unowned self] in
            self.tapSubject.onNext(self.model?.title ?? "")
        }).disposed(by: disposeBag)
    }
}
