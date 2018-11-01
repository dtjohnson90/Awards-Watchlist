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
        print("Test")
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
            print("Test 2")
            imagesReference.putData(imageData, metadata: metadata, completion: { [storage] (metadata, error) in
                print("Test 4")
                print(error)
                imagesReference.downloadURL(completion: { (url, error) in
                    print("Test 3")
                    guard let url = url else {
                        completionBlock(nil, "Error uploading: \(String(describing: error))")
                        return
                    }
                    print("Test 5")
                    completionBlock(url,nil)
                })
            })
        }
    }
}
