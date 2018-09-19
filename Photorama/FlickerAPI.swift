//
//  FlickerAPI.swift
//  Photorama
//
//  Created by Thomas Feng on 9/16/18.
//  Copyright © 2018 Infinity and Beyond. All rights reserved.
//

import Foundation

enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
}

struct FlickrAPI {
    static var interestingPhotosURL: URL {
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    
    private static let baseURLString = "https://api.flickr.com/services/rest"
    
    private static let apiKey = "ba7aefb0448212777df601855fcc64bb"
    
    private static func flickrURL(method: Method, parameters: [String:String]?) -> URL {
        
        var components = URLComponents(string: baseURLString)!
        
        var queryItems = [URLQueryItem]()
        
        let baseParams = [
            "method": method.rawValue,
            "format": "json",
            "nojsoncallback": "1",
            "api_key": apiKey
        ]
        
        for (key, value) in baseParams {
            let item = URLQueryItem(name: key, value: value)
            queryItems.append(item)
        }
        
        if let additionalParams = parameters {
            for (key, value) in additionalParams {
                let item = URLQueryItem(name: key, value: value)
                queryItems.append(item)
            }
        }
        components.queryItems = queryItems
        
        return components.url!
    }
}
