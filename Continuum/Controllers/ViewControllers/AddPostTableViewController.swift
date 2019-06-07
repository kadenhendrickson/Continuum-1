//
//  AddPostTableViewController.swift
//  Continuum
//
//  Created by Kaden Hendrickson on 6/4/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImagePickerDelegate {
    
    
    
    
    var post: Post? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField!
    @IBOutlet weak var selectImageButton: UIButton!
    
    var imagePicker: ImagePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
      
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        postImageView.image = nil
        selectImageButton.setTitle("Select Image", for: .normal)
        captionTextField.text = ""
    }
    
    func didSelect(image: UIImage?) {
        DispatchQueue.main.async {
            self.postImageView.image = image
            self.selectImageButton.setTitle("", for: .normal)
        }
        
    }
    
    @IBAction func selectImageButtonTapped(_ sender: UIButton) {
        selectImageButton.setTitle("", for: .normal)
        self.imagePicker.present(from: sender)
        
    }
    
    @IBAction func addPostButtonTapped(_ sender: Any) {
        guard let image = postImageView.image,
            let caption = captionTextField.text,
            !caption.isEmpty else {return}
        PostController.shared.createPost(image: image, caption: caption) { (_) in
            DispatchQueue.main.async {
                self.tabBarController?.selectedIndex = 0                
            }
        }
        
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    

    func updateViews(){
        guard let post = post else {return}
        postImageView.image = post.photo
        captionTextField.text = " "
    }
    }
    
//    @IBAction func selectImageFromLibrary(_ sender: UITapGestureRecognizer) {
//        let imagepickerController = UIImagePickerController()
//        imagepickerController.sourceType = .photoLibrary
//        imagepickerController.delegate = self
//        present(imagepickerController, animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {fatalError()}
//        postImageView.image = selectedImage
//        dismiss(animated: true, completion: nil)
//    }
    

    // MARK: - Table view data source




