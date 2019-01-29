//
//  ImageUploadManager.swift
//  Oscars
//
//  Created by Dustin Johnson on 11/1/18.
//  Copyright © 2018 Dustin Johnson. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

struct Constants {
    
    struct Member {
        static let imagesFolder: String = "memberImages"
    }
    
}

class ImageUploadManager: NSObject {
    func uploadImage(_ image: UIImage, progressBlock: @escaping (_ percentage: Float) -> Void, completionBlock: @escaping (_ url: URL?, _ errorMessage: String?) -> Void) {
        let storage = Storage.storage()
        let storageReference = storage.reference()
        var imagesReference = storageReference
        
        // storage/carImages/image.jpg
        let imageName = "\(Date().timeIntervalSince1970).jpg"
        imagesReference = storageReference.child(Constants.Member.imagesFolder).child(imageName)
        
        guard let imageData = UIImageJPEGRepresentation(image, 0.8) else {
            completionBlock(nil, "Image Conversion Error")
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        DispatchQueue.main.async {
            imagesReference.putData(imageData, metadata: metadata, completion: { [storage] (metadata, error) in
                imagesReference.downloadURL(completion: { (url, error) in
                    guard let url = url else {
                        completionBlock(nil, "Error uploading: \(String(describing: error))")
                        return
                    }
                    completionBlock(url,nil)
                })
            })
        }
    }   
}
