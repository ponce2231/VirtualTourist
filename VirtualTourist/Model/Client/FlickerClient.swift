//
//  FlickerClient.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 11/26/19.
//  Copyright © 2019 none. All rights reserved.
//

import Foundation


class FlickerClient {
    static let apiKey = "3623755d3cbcf0330df4978a63d7d7ba"
    
    
    enum EndPoints {
        static let base = "https://www.flickr.com/services/rest/?method="
        static let apiKeyParameter = "&api_key=\(FlickerClient.apiKey)"
        //temporary variable
        case getPhotosLocation(Int)
        case photoSearch(Double,Double)
        
        var urlValue:String{
            switch self {
            case .getPhotosLocation(let photoID): return EndPoints.base + "flickr.photos.geo.getLocation" + EndPoints.apiKeyParameter + "&photo_id=\(photoID)" + "&format=json&nojsoncallback=1"
            case .photoSearch(let lat, let long): return EndPoints.base + "flickr.photos.search" + EndPoints.apiKeyParameter + "&lat=\(lat)" + "&lon=\(long)" + "&per_page=5&page=1&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL{
            return URL(string: urlValue)!
        }
    }
    
    
    class func photoSearchLocation(latitude: Double, longitude: Double, completionHandler: @escaping(Bool,Error?) -> Void){
        
        var request = URLRequest(url: EndPoints.photoSearch(latitude, longitude).url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else{
                print("bananas")
                dump(error?.localizedDescription)
                completionHandler(false,error)
                return
            }
            print(data)
            

            do{
                let decoder = JSONDecoder()
                let photoSearchResponse = try decoder.decode(PhotoSearchResponse.self, from: data)
                for pictID in photoSearchResponse.photos.photo{
                    dump(pictID.id)
                }
               
                completionHandler(true,nil)
            }catch{
                print("hamburger")
                dump(error.localizedDescription)
                completionHandler(false,error)
            }
        
        }
        dataTask.resume()
    }
    
    class func getPhotoGeoLocation(photoID:Int, completionHandler: @escaping (Bool,Error?) -> Void) {
        
    }
}
