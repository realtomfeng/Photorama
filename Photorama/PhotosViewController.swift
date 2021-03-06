//
//  PhotosViewController.swift
//  Photorama
//
//  Created by Thomas Feng on 9/16/18.
//  Copyright © 2018 Infinity and Beyond. All rights reserved.
//

//import Foundation
import UIKit

class PhotosViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet var collectionView: UICollectionView!

    var store: PhotoStore!
    var photoDataSource = PhotoDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = photoDataSource
        collectionView.delegate = self
        
        updateDataSource()
    
        store.fetchInterestingPhotos {
            (photosResult) -> Void in
            self.updateDataSource()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showPhoto"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
                let photo = photoDataSource.photos[selectedIndexPath.row]
                let destinationVC = segue.destination as! PhotoInfoViewController
                destinationVC.photo = photo
                destinationVC.store = store
            }
        default:
            preconditionFailure("Unexpected Segue Indentifier")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                           willDisplay cell: UICollectionViewCell,
                           forItemAt indexPath: IndexPath) {
        
        let photo = photoDataSource.photos[indexPath.row]
                store.fetchImage(for: photo) { (result) -> Void in
            guard let photoIndex = self.photoDataSource.photos.index(of: photo),
                case let .success(image) = result else {
                    return
            }
            let photoIndexPath = IndexPath(item: photoIndex, section: 0)
            
            if let cell = self.collectionView.cellForItem(at: photoIndexPath)
                as? PhotoCollectionViewCell {
                cell.update(with: image)
            }
        }
    }
    
    private func updateDataSource() {
        store.fetchAllPhotos {
            (PhotosResult) in
            
            switch PhotosResult {
            case let .success(photos):
                self.photoDataSource.photos = photos
            case .failure:
                self.photoDataSource.photos.removeAll()
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}
