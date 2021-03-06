//
//  FlickerClient.swift
//  VirtualTourist
//
//  Created by Christopher Ponce Mendez on 11/26/19.
//  Copyright © 2019 none. All rights reserved.
//

import Foundation

// create attributes for url image and where to store them 
class FlickerClient {
    static let apiKey = "3623755d3cbcf0330df4978a63d7d7ba"
    
    
    enum EndPoints {
        static let base = "https://www.flickr.com/services/rest?method="
        static let apiKeyParameter = "&api_key=\(FlickerClient.apiKey)"
        
        //add safe search parameter
        //add boundbox parameter it cannot be too small
        case photoSearch(String,Double,Double,Int)
        
        var urlValue:String{
            switch self {
            case .photoSearch(let bbox,let lat, let long, let page): return EndPoints.base + "flickr.photos.search" + EndPoints.apiKeyParameter + "&bbox=\(bbox)" + "&accuracy=11" + "&safe_search=1" + "&lat=\(lat)" + "&lon=\(long)" + "&extras=url_m" + "&per_page=21" + "&page=\(page)" + "&format=json&nojsoncallback=1"
            }
        }
        //        + "&per_page=20"
        var url: URL{
            return URL(string: urlValue)!
        }
    }
    
    class func photoSearchLocation(latitude: Double, longitude: Double, completionHandler: @escaping(Bool,Error?, [String]?) -> Void){
        //add bbox on the dictionary
        var parameterDic = ["bbox": self.bboxString(latitud: latitude, longitude: longitude),"lat" : latitude, "lon" : longitude, "page" : "page"] as [String:Any]
        
        parameterDic["page"] = pageCounter
        
        let request = URLRequest(url: EndPoints.photoSearch( parameterDic["bbox"] as! String, parameterDic["lat"] as! Double,parameterDic["lon"] as! Double, parameterDic["page"] as! Int).url)
        print(request)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard let data = data, error == nil else{
                print("guard let data called")
                dump(error?.localizedDescription)
                completionHandler(false,error,[])
                return
            }
            
            do{
                
                let decoder = JSONDecoder()
                let photoSearchResponse = try decoder.decode(PhotoSearchResponse.self, from: data)
                var urlImage = [String]()
                for pictID in photoSearchResponse.photos.photo{
                    urlImage.append(pictID.urlM)
                    
                }
                
                
                DispatchQueue.main.async {
                    parameterDic.updateValue(1..., forKey: "page")
                    completionHandler(true,nil,urlImage)
                }
                
            }catch{
                dump(error.localizedDescription)
                DispatchQueue.main.async {
                    completionHandler(false,error,[])
                }
            }
            
        }
        dataTask.resume()
    }
    //    MARK: BBox Variables
    static let latRange = (-90.0,90.0)
    static let longRange = (-180.0,180.0)
    static let squareWidth = 0.5
    static let squareHeight = 0.5
    class func bboxString(latitud:Double, longitude:Double) -> String{
        
        let maxLat = max(latitud + self.squareHeight, FlickerClient.latRange.0)
        let maxLong = max(longitude + self.squareWidth, FlickerClient.longRange.0)
        let minLat = min(latitud - self.squareHeight, FlickerClient.latRange.1)
        let minLong = min(longitude - self.squareWidth, FlickerClient.longRange.1)
        
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
}
