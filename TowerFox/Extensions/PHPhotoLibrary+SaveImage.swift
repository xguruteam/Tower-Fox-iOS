//
//  PHPhotoLibrary+SaveImage.swift
//  TestPH
//
//  Created by Guru on 6/8/19.
//  Copyright © 2019 Luccas. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension PHPhotoLibrary {
    
    func save(image: UIImage, path: String, completion: ((PHAsset?) -> ())? = nil) {
        func save() {
            let rootName = Bundle.main.infoDictionary!["CFBundleName"] as! String
            
            if let root = PHPhotoLibrary.shared().findRootFolderWith(name: rootName) {
                PHPhotoLibrary.shared().searchAlbumAndSave(image: image, path: path, parent: root) { (asset) in
                    completion?(asset)
                }
            } else {
                PHPhotoLibrary.shared().createRootFolderWith(name: rootName, completion: { (collection) in
                    if let collection = collection {
                        PHPhotoLibrary.shared().searchAlbumAndSave(image: image, path: path, parent: collection, completion: { (asset) in
                            completion?(asset)
                        })
                    } else {
                        completion?(nil)
                    }
                })
            }
        }
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            save()
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    save()
                }
            })
        }
    }
    
    func createRootFolderWith(name: String, completion: @escaping (PHCollectionList?)->()) {
        var folderPlaceholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            let createFolderRequest = PHCollectionListChangeRequest.creationRequestForCollectionList(withTitle: name)
            let placeholder = createFolderRequest.placeholderForCreatedCollectionList
            folderPlaceholder = placeholder
        }, completionHandler: { success, error in
            guard let folderPlaceHolder = folderPlaceholder else {
                completion(nil)
                return
            }
            if success {
                let fetchResult = PHCollectionList.fetchCollectionLists(withLocalIdentifiers: [folderPlaceHolder.localIdentifier], options: nil)
                guard let folder = fetchResult.firstObject else {
                    completion(nil)
                    return
                }
                completion(folder)
            } else {
                completion(nil)
            }
        })
    }
    
    fileprivate func findRootFolderWith(name: String) -> PHCollectionList? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let fetchResult : PHFetchResult = PHCollectionList.fetchCollectionLists(with: .folder, subtype: .any, options: fetchOptions)
        guard let root = fetchResult.firstObject else {
            return nil
        }
        return root
    }
    
    fileprivate func searchAlbumAndSave(image: UIImage, path: String, parent: PHCollectionList, completion: @escaping ((PHAsset?) -> ())) {
        var dirs = path.split(separator: "/")
        let count = dirs.count
        guard count > 0 else {
            completion(nil)
            return
        }
        
        let name = String(dirs.first!)
        
        if count > 1 {
            dirs.removeFirst()
            let childPath = dirs.joined(separator: "/")
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", name)
            let fetchResult = PHCollectionList.fetchCollections(in: parent, options: fetchOptions)
            
            if let folder = fetchResult.firstObject as? PHCollectionList {
                searchAlbumAndSave(image: image, path: childPath, parent: folder, completion: completion)
            }
            else {
                createFolder(name: name, parent: parent) { [weak self] (newFolder) in
                    if let newFolder = newFolder {
                        self?.searchAlbumAndSave(image: image, path: childPath, parent: newFolder, completion: completion)
                    }
                    else {
                        completion(nil)
                    }
                }
            }
            return
        }
        
        // count == 1; last path component
        // create an album
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let fetchResult : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let album = fetchResult.firstObject {
            saveImage(image: image, album: album, completion: completion)
        }
        else {
            createAlbum(albumName: name, parent: parent) { (newAlbum) in
                if let newAlbum = newAlbum {
                    self.saveImage(image: image, album: newAlbum, completion: completion)
                }
                else {
                    completion(nil)
                }
            }
        }
    }
    
    fileprivate func createFolder(name: String, parent: PHCollectionList, completion: @escaping (PHCollectionList?)->()) {
        var folderPlaceholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            let createFolderRequest = PHCollectionListChangeRequest.creationRequestForCollectionList(withTitle: name)
            guard let parentChangeRequest = PHCollectionListChangeRequest(for: parent) else { return }
            
            let placeholder = createFolderRequest.placeholderForCreatedCollectionList
            folderPlaceholder = placeholder
            
            let fastEnumeration = NSArray(array: [placeholder] as [PHObjectPlaceholder])
            parentChangeRequest.addChildCollections(fastEnumeration)
            
        }, completionHandler: { success, error in
            guard let folderPlaceHolder = folderPlaceholder else {
                completion(nil)
                return
            }
            
            if success {
                let fetchResult = PHCollectionList.fetchCollectionLists(withLocalIdentifiers: [folderPlaceHolder.localIdentifier], options: nil)
                guard let folder = fetchResult.firstObject else {
                    completion(nil)
                    return
                }
                completion(folder)
            } else {
                completion(nil)
            }
        })
    }
    
    fileprivate func createAlbum(albumName: String, parent: PHCollectionList, completion: @escaping (PHAssetCollection?)->()) {
        var albumPlaceholder: PHObjectPlaceholder?
        
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            guard let parentChangeRequest = PHCollectionListChangeRequest(for: parent) else { return }
            
            let placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
            albumPlaceholder = placeholder
            
            let fastEnumeration = NSArray(array: [placeholder] as [PHObjectPlaceholder])
            parentChangeRequest.addChildCollections(fastEnumeration)
            
        }, completionHandler: { success, error in
            if success {
                guard let placeholder = albumPlaceholder else {
                    completion(nil)
                    return
                }
                let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                guard let album = fetchResult.firstObject else {
                    completion(nil)
                    return
                }
                completion(album)
            } else {
                completion(nil)
            }
        })
    }
    
    fileprivate func saveImage(image: UIImage, album: PHAssetCollection, completion:((PHAsset?)->())? = nil) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAssetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            guard let albumChangeRequest = PHAssetCollectionChangeRequest(for: album),
                let photoPlaceholder = createAssetRequest.placeholderForCreatedAsset else { return }
            placeholder = photoPlaceholder
            let fastEnumeration = NSArray(array: [photoPlaceholder] as [PHObjectPlaceholder])
            albumChangeRequest.addAssets(fastEnumeration)
        }, completionHandler: { success, error in
            guard let placeholder = placeholder else {
                completion?(nil)
                return
            }
            if success {
                let assets:PHFetchResult<PHAsset> =  PHAsset.fetchAssets(withLocalIdentifiers: [placeholder.localIdentifier], options: nil)
                let asset:PHAsset? = assets.firstObject
                completion?(asset)
            } else {
                completion?(nil)
            }
        })
    }
}
