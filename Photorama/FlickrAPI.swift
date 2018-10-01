//
//  FlickerAPI.swift
//  Photorama
//
//  Created by Thomas Feng on 9/16/18.
//  Copyright © 2018 Infinity and Beyond. All rights reserved.
//

import Foundation

enum flickrError: Error {
    case invalidJSONData
}

enum Method: String {
    case interestingPhotos = "flickr.interestingness.getList"
    
    case recentPhotos = "flickr.photos.getRecent"
}

struct FlickrAPI {
    static var interestingPhotosURL: URL {
        return flickrURL(method: .interestingPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    static var recentPhotosURL: URL {
        return flickrURL(method: .recentPhotos, parameters: ["extras": "url_h,date_taken"])
    }
    private static let baseURLString = "https://api.flickr.com/services/rest"
    private static let apiKey = "ba7aefb0448212777df601855fcc64bb"
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
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
    
    private static func photo(fromJSON json: [String:Any]) -> Photo? {
        guard
            let photoID = json["id"] as? String,
            let title = json["title"] as? String,
            let dateString = json["datetaken"] as? String,
            let photoURLString = json["url_h"] as? String,
            let url = URL(string: photoURLString),
            let dateTaken = dateFormatter.date(from: dateString)
            else {
                return nil
        }
        
        return Photo(title: title, remoteURL: url, photoID: photoID, dateTaken: dateTaken) //creates a Photo object with the parameters from the parsed JSON
    }
    
    static func photos(fromJSON data: Data) -> PhotosResult { //This gets called from the PhotoStore with the data to parse the data
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any], //created a dictionary of JSON
                let photos = jsonDictionary["photos"] as? [String:Any], //takes only the photos bit of the data
                let photosArray = photos["photo"] as? [[String:Any]] //takes the photo part of the photos which is an array
                else {
                        return .failure(flickrError.invalidJSONData)
            }
            var finalPhotos = [Photo]()
            for photoJSON in photosArray {
                if let photo = photo(fromJSON: photoJSON) { //This calls the photo function to convert the parsed data into Photo objects
                finalPhotos.append(photo)
                }
            }
            if finalPhotos.isEmpty && !photosArray.isEmpty {
                return .failure(flickrError.invalidJSONData)
            }
            return .success(finalPhotos)
        } catch let error {
            return .failure(error)
        }
    }
}
