//
//  ResponseItem.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import Foundation

//struct ResultItem<T: Codable>: Codable {
//    
//}

struct ResponseItem<T: Codable>: Codable {
    let data: [T]?
    
    enum CodingKeys : String, CodingKey {
        case data = "results"
    }
}
