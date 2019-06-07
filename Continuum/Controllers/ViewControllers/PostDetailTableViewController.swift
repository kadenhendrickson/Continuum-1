//
//  PostDetailTableViewController.swift
//  Continuum
//
//  Created by Kaden Hendrickson on 6/5/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {

    var post: Post? {
        didSet {
            loadViewIfNeeded()  
            updateViews()
        }
    }
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var followButtonText: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let post = post else {return}
        PostController.shared.fetchComments(post: post) { (comments) in
            guard let comments = comments else {return}
            post.comments = comments
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    fileprivate func showAlertController() {
        let alertController = UIAlertController(title: "Comment?", message: "Add a comment here!", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "type your comment here..."
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            guard let text = alertController.textFields?[0].text,
                !text.isEmpty,
                let post = self.post else {return}
            PostController.shared.addComment(text: text, post: post, completion: { (_) in
            })
            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func commentButton(_ sender: Any) {
        showAlertController()
    }
    
    @IBAction func shareButton(_ sender: Any) {
        guard let post = post else {return}
        let activityController = UIActivityViewController(activityItems: [post], applicationActivities: nil)
        present(activityController, animated: true)
    }
    
    @IBAction func followButton(_ sender: Any) {
        guard let post = post  else {return}
        PostController.shared.toggleSubscriptionTo(commentsForPost: post) { (success, _) in
            guard let success = success else {return}
            if success {
                DispatchQueue.main.async {
                    self.updateViews()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func updateViews() {
        guard let post = post else {return}
        photoImageView.image = post.photo
        PostController.shared.checkSubscription(to: post) { (success) in
            DispatchQueue.main.async {
                if success {
                    self.followButtonText.setTitle("Following", for: .normal)
                    self.followButtonText.setTitleColor(UIColor.green, for: .normal)
                } else {
                    self.followButtonText.setTitle("Follow", for: .normal)
                    self.followButtonText.setTitleColor(UIColor.blue, for: .normal)
                }
            }
    
        }
    }
    


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = post else {return 0}
        return post.comments.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath)
        let comment = post?.comments[indexPath.row]
        cell.textLabel?.text = comment?.text
        cell.detailTextLabel?.text = (comment?.timestamp as Date?)?.toString()
        return cell
    }
    
}
