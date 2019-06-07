//
//  Post.swift
//  Continuum
//
//  Created by Kaden Hendrickson on 6/4/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

struct Constants {
    static let recordKey = "Post"
    static let photoKey = "photo"
    static let timestampKey = "timestamp"
    static let captionKey = "caption"
    static let commentKey = "comments"
    static let commentCountKey = "commentCount"
    static let imageAssetKey = "imageAsset"
}

class Post: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        if self.caption.lowercased().contains(searchTerm.lowercased()) {
            return true
        }
        for comment in comments {
            if comment.matches(searchTerm: searchTerm) {
                return true
            }
        }
        return false
    }
    
    var photoData: Data?
    let timestamp: Date
    let caption: String
    var commentCount: Int
    var comments: [Comment]
    let recordID: CKRecord.ID
    var photo: UIImage? {
        get {
            guard let photoData = photoData else {return nil}
            return UIImage(data: photoData)
        } set {
            photoData = newValue?.jpegData(compressionQuality: 0.5)
            
        }
    }
    
    
    init(photo: UIImage, caption: String, timestamp: Date = Date(), comments: [Comment] = [], commentCount: Int = 0, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.timestamp = timestamp
        self.caption = caption
        self.comments = comments
        self.commentCount = commentCount
        self.recordID = recordID
        self.photo = photo
    }
    

    convenience init?(ckRecord: CKRecord) {
               guard let timestamp = ckRecord[Constants.timestampKey] as? Date,
                let caption = ckRecord[Constants.captionKey] as? String,
                let imageAsset = ckRecord[Constants.imageAssetKey] as? CKAsset,
                let commentCount = ckRecord[Constants.commentCountKey] as? Int else {return nil}
        
        let photoData = try? Data(contentsOf: imageAsset.fileURL)
        
        self.init(photo: UIImage(data: photoData!) ?? UIImage(), caption: caption, timestamp: timestamp, commentCount: commentCount, recordID: ckRecord.recordID)
            }
}

extension CKRecord {
    convenience init(post: Post) {
        
        self.init(recordType: Constants.recordKey, recordID: post.recordID)
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = URL(fileURLWithPath: temporaryDirectory)
        let fileURL = temporaryDirectoryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        do {
            try post.photoData?.write(to: fileURL)
        } catch {
            print("There was an error saving image data to url: \(error.localizedDescription)")
        }
        
        let imageAsset = CKAsset(fileURL: fileURL)
        
        self.setValue(post.photoData, forKey: Constants.photoKey)
        self.setValue(post.timestamp, forKey: Constants.timestampKey)
        self.setValue(post.caption, forKey: Constants.captionKey)
        self.setValue(post.commentCount, forKey: Constants.commentCountKey)
        self.setValue(imageAsset, forKey: Constants.imageAssetKey)
        
    }
}

