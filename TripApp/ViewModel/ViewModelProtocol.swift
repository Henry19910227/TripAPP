//
//  ViewModelProtocol.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import Foundation

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    func transform(input: Input?) -> Output
    func clear()
}
