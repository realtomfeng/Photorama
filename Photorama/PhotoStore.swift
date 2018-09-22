//
//  PhotoStore.swift
//  Photorama
//
//  Created by Thomas Feng on 9/16/18.
//  Copyright © 2018 Infinity and Beyond. All rights reserved.
//

import Foundation

enum PhotosResult {
    case success([Photo])
    case failure(Error)
}

class PhotoStore {
    
    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    private func processPhotosRequest(data: Data?, error: Error?) -> PhotosResult {
            guard let jsonData = data else {
                return .failure(error!)
            }
            return FlickrAPI.photos(fromJSON: jsonData)
    }
    
    
    func fetchInterestingPhotos(completion: @escaping (PhotosResult) -> Void) {
        let url = FlickrAPI.interestingPhotosURL
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) -> Void in //This closure is called when this request finishes and data is recieved if possible
            let result = self.processPhotosRequest(data: data, error: error)
            completion(result)
        }
    task.resume()
    }
}
