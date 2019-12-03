//
//  PhotoSearchResponse.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 12/2/19.
//  Copyright © 2019 none. All rights reserved.
//
import Foundation

// MARK: - PhotoSearchResponse
struct PhotoSearchResponse: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page: Int
    let pages: String
    let perpage: Int
    let total: String
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
