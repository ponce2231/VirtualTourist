//
//  GetLocationResponse.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 11/29/19.
//  Copyright © 2019 none. All rights reserved.
//

import Foundation
class GetLocationResponse: Codable {
    let apiKey: String
    let photoID: Int
    
    enum CodingKeys: String, CodingKey{
        case apiKey = "api_key"
        case photoID = "photo_id"
    }
}
