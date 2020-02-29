//
//  URLProtocol.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import Foundation

protocol TripURL {
    var apiAllTripsURL: URL { get }
}

extension TripURL {
    var apiAllTripsURL: URL { return URL(string: "http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=36847f3f-deff-4183-a5bb-800737591de5&limit=10&offset=0")! }
}
