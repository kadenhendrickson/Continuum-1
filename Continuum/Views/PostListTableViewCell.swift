//
//  PostListTableViewCell.swift
//  Continuum
//
//  Created by Kaden Hendrickson on 6/4/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewCell: UITableViewCell {
    
    var post: Post? {
        didSet{
            updateViews()
        }
    }
    
    @IBOutlet weak var captionTextLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var commentCountTextLabel: UILabel!
    
    func updateViews() {
        captionTextLabel.text = post?.caption
        postImageView.image = post?.photo
        commentCountTextLabel.text = "Comments: \(post?.commentCount ?? 0)"
    }
    

}
