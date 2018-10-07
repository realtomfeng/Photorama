//
//  PhotoInfoViewController.swift
//  Photorama
//
//  Created by Thomas Feng on 10/7/18.
//  Copyright © 2018 Infinity and Beyond. All rights reserved.
//

import Foundation
import UIKit

class PhotoInfoViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            navigationItem.title = photo.title
        }
    }
    var store: PhotoStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchImage(for: photo) { (result) -> Void in
            switch result {
            case let .success(image):
                self.imageView.image = image
            case let .failure(error):
                print("Error fetching image for photo: \(error)")
            }
        }
    }
}
