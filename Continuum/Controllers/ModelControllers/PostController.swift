//
//  PostController.swift
//  Continuum
//
//  Created by Kaden Hendrickson on 6/4/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    //Singleton
    static let shared = PostController()
    
    init() {
        
//        subscribeToNewPosts { (_, _) in
//        }
    }
    //Source of truth
    var posts: [Post] = []
    
    //database
    let publicDB = CKContainer.default().publicCloudDatabase
    
    //CRUD Functions
    
        //AddComment
    func addComment(text: String, post: Post, completion: @escaping (Comment?) -> Void) {
        let comment = Comment(text: text, post: post)
        post.commentCount += 1
       
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [CKRecord(post: post)], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .changedKeys
        publicDB.add(modifyOperation)
        
        post.comments.append(comment)
        let commentRecord = CKRecord(comment: comment)
        publicDB.save(commentRecord) { (record, error) in
            if let error = error {
                print("😝 There was an error in \(#function) : \(error) : \(error.localizedDescription) 😝")
                completion(nil)
                return
            }
            guard let record = record, let comment = Comment(ckRecord: record, post: post) else {completion(nil); return}
            completion(comment)

     }
    }
        //CreatePost
    func createPost(image: UIImage, caption: String, completion: @escaping (Post?) -> Void) {
        let post = Post(photo: image, caption: caption)
        self.posts.append(post)
        let postRecord = CKRecord(post: post)
        publicDB.save(postRecord) { (record, error) in
            if let error = error {
                print("😝 There was an error in \(#function) : \(error) : \(error.localizedDescription) 😝")
                return
            }
            guard let record = record,
                    let post = Post(ckRecord: record) else {completion(nil); return}
            completion(post)
        }
    }
   
    //LoadFromCloudKit
    func fetchPost(completion: @escaping ([Post]?) -> Void) {
        
        let predicate = NSPredicate(value:  true)
        let query = CKQuery(recordType: Constants.recordKey, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("😝 There was an error in \(#function) : \(error) : \(error.localizedDescription) 😝")
                completion(nil)
                return
            }
            guard let records = records else {completion(nil); return}
            let posts = records.compactMap({Post(ckRecord: $0)})
            self.posts = posts
            completion(posts)
        }
        
    }
    
    func fetchComments(post: Post, completion: @escaping ([Comment]?) -> Void) {
        let postReference = post.recordID
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, postReference)
        let commentIDs = post.comments.compactMap({$0.recordID})
        let predicate2 = NSPredicate(format: "NOT(recordID IN %@)", commentIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate, predicate2])
        let query = CKQuery(recordType: CommentConstants.recordKey, predicate: compoundPredicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("😝 There was an error in \(#function) : \(error) : \(error.localizedDescription) 😝")
                completion(nil)
                return
            }
            guard let records = records else {completion(nil); return}
            let comments = records.compactMap {Comment(ckRecord: $0, post: post)}
            post.comments.append(contentsOf: comments)
            completion(comments)
            
        }
    }
    
    func subscribeToNewPosts(completion: @escaping (Bool?, Error?) -> Void) {
        let predicate = NSPredicate(value: true)
        let ckQuerySubscription = CKQuerySubscription(recordType: Constants.recordKey, predicate: predicate)
        
        publicDB.save(ckQuerySubscription) { (subscription, error) in
            if let error = error {
                print("😝 There was an error in \(#function) : \(error) : \(error.localizedDescription) 😝")
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func addSubscriptionTo(commentsForPost post: Post, completion: @escaping (Bool?, Error?) -> Void) {
        let predicate = NSPredicate(format: "%K == %@", CommentConstants.postReferenceKey, post.recordID)
        let ckQuerySubscription = CKQuerySubscription(recordType: CommentConstants.recordKey, predicate: predicate, subscriptionID: post.recordID.recordName, options: CKQuerySubscription.Options.firesOnRecordCreation)
       
        let ckSubscriptionNotificationInfo = CKSubscription.NotificationInfo()
        ckSubscriptionNotificationInfo.alertBody = "There is a new comment on one of the posts you follow!"
        ckSubscriptionNotificationInfo.shouldSendContentAvailable = true
        ckSubscriptionNotificationInfo.desiredKeys = [post.recordID.recordName]
        ckQuerySubscription.notificationInfo = ckSubscriptionNotificationInfo
        
        
        publicDB.save(ckQuerySubscription) { (subsription, error) in
            if let error = error {
                print("😝 There was an error in \(#function) : \(error) : \(error.localizedDescription) 😝")
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    func removeSubscriptionTo(commentsForPost post: Post, completion: @escaping (Bool?, Error?) -> Void) {
        PostController.shared.publicDB.delete(withSubscriptionID: post.recordID.recordName) { (_, error) in
            if let error = error {
                print("😝 There was an error in \(#function) : \(error) : \(error.localizedDescription) 😝")
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
    
    func checkSubscription(to post: Post, completion: @escaping (Bool) -> Void) {
        PostController.shared.publicDB.fetch(withSubscriptionID: post.recordID.recordName) { (subscription, error) in
            if let error = error {
                print("😝 There was an error in \(#function) : \(error) : \(error.localizedDescription) 😝")
                completion(false)
                return
            }
            if subscription != nil { completion(true) }
            else { completion(false) }
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: @escaping (Bool?, Error?) -> Void) {
        checkSubscription(to: post) { (success) in
            if !success {
                PostController.shared.addSubscriptionTo(commentsForPost: post, completion: { (_, _) in
                })
            } else {
                self.removeSubscriptionTo(commentsForPost: post, completion: { (_, _) in
                })
            }
        }
    }
}
