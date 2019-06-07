//
//  Comment.swift
//  Continuum
//
//  Created by Kaden Hendrickson on 6/4/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import Foundation
import CloudKit

struct CommentConstants {
    static let recordKey = "Comment"
    static let textKey = "text"
    static let timestampKey = "timestamp"
    static let postKey = "post"
    static let postReferenceKey = "postReference"
}

class Comment: SearchableRecord {
    
    func matches(searchTerm: String) -> Bool {
        return text.lowercased().contains(searchTerm.lowercased())
    }
    
    let text: String
    let timestamp: Date
    weak var post: Post?
    let recordID: CKRecord.ID
    var postReference: CKRecord.Reference? {
        guard let post = post else {return nil}
        return CKRecord.Reference(recordID: post.recordID, action: .deleteSelf)
    }
    
    init(text: String,  post: Post?, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)){
        self.text = text
        self.timestamp = timestamp
        self.post = post
        self.recordID = recordID
        
    }
    convenience init?(ckRecord: CKRecord, post: Post) {
        guard let text = ckRecord[CommentConstants.textKey] as? String,
            let timestamp = ckRecord[CommentConstants.timestampKey] as? Date else {return nil}
        self.init(text: text, post: post, timestamp: timestamp, recordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init (comment: Comment){

        self.init(recordType: CommentConstants.recordKey, recordID: comment.recordID)
        self.setValue(comment.text, forKey: CommentConstants.textKey)
        self.setValue(comment.timestamp, forKey: CommentConstants.timestampKey)
        //self.setValue(comment.post, forKey: CommentConstants.postKey)
        self.setValue(comment.postReference, forKey: CommentConstants.postReferenceKey)
        
    }
}


