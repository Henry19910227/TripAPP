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

class TripCellViewModel {
    public var title: Observable<String>?
    public var content: Observable<String>?
    public var images: Observable<[SectionModel<String, String>]>?
    public var model: Trip? {
        didSet {
            guard let model = model else { return }
            title = Observable.just(model.title)
            content = Observable.just(model.content)
            images = Observable.just(model.images).map({ (imageStr) -> [SectionModel<String, String>] in
                let imgs = imageStr.components(separatedBy: "http://")
                let result = imgs.filter { (img) -> Bool in
                    return img.hasSuffix(".jpg") || img.hasSuffix(".JPG")
                }.map { (img) -> String in
                    return "https://\(img)"
                }
                return [SectionModel(model: "TripImage", items: result)]
            })
        }
    }
}
