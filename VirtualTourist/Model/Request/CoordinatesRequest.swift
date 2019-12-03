//
//  CoordinatesRequest.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 12/2/19.
//  Copyright © 2019 none. All rights reserved.
//

import Foundation
struct CoordinatesRequest: Codable {
    let latitude: String
    let longitude: String
    
    enum CodingKeys: String,CodingKey {
        case latitude = "lat"
        case longitude = "lon"
    }
}
