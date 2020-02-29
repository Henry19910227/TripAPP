//
//  Trip.swift
//  TripApp
//
//  Created by 廖冠翰 on 2020/2/23.
//  Copyright © 2020 廖冠翰. All rights reserved.
//

import Foundation

struct Trip: Codable {
    let title: String
    let content: String
    let images: String
    
    enum CodingKeys : String, CodingKey {
        case title = "stitle"
        case content = "xbody"
        case images = "file"
    }
}
