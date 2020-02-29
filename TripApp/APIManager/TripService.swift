//
//  TripService.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import SwiftyJSON

class TripService: APIRequest, TripURL, APIDataTransform {
    
    func apiTrips(parameter: [String: Any]?) -> Single<ResponseItem<Trip>> {
        return Single<ResponseItem<Trip>>.create(subscribe: {[unowned self] (single) -> Disposable in
            let _ = self.apiRequest(medthod: .get, url: self.apiAllTripsURL, parameter: parameter)
                .map({ (dict) -> ResponseItem<Trip>? in
                    guard let result = dict["result"] as? Dictionary<String, Any> else { return nil }
                    return self.dataTransform(dict: result)
                }).subscribe(onSuccess: { (responseItem) in
                    guard let responseItem = responseItem else {  return single(.error(APIError.DecodeError)) }
                    single(.success(responseItem))
                }, onError: { (error) in
                    single(.error(APIError.RequestError))
                })
            return Disposables.create()
        })
    }
}
