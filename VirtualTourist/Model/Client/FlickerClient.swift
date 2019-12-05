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
        
        //add safe search parameter
        //add boundbox parameter it cannot be too small
        case photoSearch(String,Double,Double)
        
        var urlValue:String{
            switch self {
            case .photoSearch(let bbox,let lat, let long): return EndPoints.base + "flickr.photos.search" + EndPoints.apiKeyParameter + "&bbox=\(bbox)" + "&lat=\(lat)" + "&lon=\(long)" + "&extras=url_m" + "&per_page=5" + "&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL{
            return URL(string: urlValue)!
        }
    }
    
    //boundBox:Double,extras: String,
    class func photoSearchLocation(latitude: Double, longitude: Double, completionHandler: @escaping(Bool,Error?) -> Void){
        //add bbox on the dictionary
        let parameterDic = ["bbox": ,"lat" : latitude, "lon" : longitude] as [String:Any]
        let request = URLRequest(url: EndPoints.photoSearch(  parameterDic["lat"] as! Double,parameterDic["lon"] as! Double).url)
        
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
                    dump(pictID.urlM)
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
    
    private func bboxString(latitud:Double, longitude:Double) -> String{
        
        let minLat = max(latitud - 0.5, FlickerClient.latRange.0)
        let minLong = max(longitude - 0.5, FlickerClient.longRange.0)
        let maxLat = min(latitud + 0.5, FlickerClient.latRange.1)
        let maxLong = min(latitud + 0.5, FlickerClient.longRange.1)
        
        return "\(minLat),\(minLong),\(maxLat),\(maxLong)"
    }
    static let latRange = (-90.0,90.0)
    static let longRange = (-180.0,180.0)
}
