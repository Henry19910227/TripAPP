//
//  APIProtocol.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxAlamofire
import Alamofire

enum APIError: Error {
    case DecodeError
    case NullData
    case RequestError
}

protocol APIRequest {
    func sendRequest<T: Codable>(medthod: HTTPMethod, url: URL, parameter: [String: Any]?) -> Single<ResponseItem<T>>
    func apiRequest(medthod: HTTPMethod, url: URL, parameter: [String: Any]?) -> Single<Dictionary<String, Any>>
}

protocol APIDataTransform {
    func dataTransform<T: Codable>(dict: Dictionary<String, Any>) -> ResponseItem<T>?
}

extension APIRequest {
    func sendRequest<T: Codable>(medthod: HTTPMethod, url: URL, parameter: [String: Any]?) -> Single<ResponseItem<T>> {
        return Single<ResponseItem<T>>.create(subscribe: { (single) -> Disposable in
            let _ = request(medthod, url, parameters: parameter)
                .data()
                .map({ (data) -> ResponseItem<T>? in
                    do {
                        //轉成Dict
                        let dict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! Dictionary<String, Any>
                        //取出result的內容
                        guard let result = dict["result"] as? Dictionary<String, Any> else {
                            return nil
                        }
                        //轉回 Data
                        let dictData = try! JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)
                        //將 data 轉成 model
                        let responseItem = try JSONDecoder().decode(ResponseItem<T>.self, from: dictData)
                        return responseItem
                    } catch {
                        return nil
                    }
                }).subscribe(onNext: { (responseItem) in
                    guard let item = responseItem else {
                        return single(.error(APIError.DecodeError))
                    }
                    single(.success(item))
                }, onError: { (error) in
                    single(.error(APIError.RequestError))
                })
            return Disposables.create()
        })
    }
    
    func apiRequest(medthod: HTTPMethod, url: URL, parameter: [String: Any]?) -> Single<Dictionary<String, Any>> {
        return Single<Dictionary<String, Any>>.create(subscribe: { (single) -> Disposable in
            let _ = request(medthod, url, parameters: parameter)
                .data()
                .map({ (data) -> Dictionary<String, Any>? in
                    do {
                        //轉成Dict
                        let dataDict = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Dictionary<String, Any>
                        return dataDict
                    } catch {
                        return nil
                    }
                }).subscribe(onNext: { (dataDict) in
                    guard let item = dataDict else {
                        return single(.error(APIError.DecodeError))
                    }
                    single(.success(item))
                }, onError: { (error) in
                    single(.error(APIError.RequestError))
                })
            return Disposables.create()
        })
    }
}

extension APIDataTransform {
    func dataTransform<T: Codable>(dict: Dictionary<String, Any>) -> ResponseItem<T>? {
        do {
            //轉回 Data
            let dictData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            //將 data 轉成 model
            let responseItem = try JSONDecoder().decode(ResponseItem<T>.self, from: dictData)
            return responseItem
        } catch {
            return nil
        }
    }
}
