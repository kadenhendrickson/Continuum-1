//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Kaden Hendrickson on 6/4/19.
//  Copyright © 2019 trevorAdcock. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, UISearchBarDelegate {

    
    var resultsArray: [Post] = []
    var isSearching: Bool = false
    var dataSource: [Post] { //searchable record??
        return isSearching ? resultsArray: PostController.shared.posts
    }

    @IBOutlet var searchBar: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        resultsArray = PostController.shared.posts
        tableView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestFullSyncOperation { (_) in
        }
        
        
        
    }
    
    func requestFullSyncOperation(completion: @escaping (Bool?) -> Void ) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        PostController.shared.fetchPost { (posts) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostListTableViewCell
        cell?.post = dataSource[indexPath.row]

        return cell ?? UITableViewCell()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetailVC" {
            guard let index = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? PostDetailTableViewController else {return}
            let post = dataSource[index.row]
            destinationVC.post = post
        }
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        resultsArray = dataSource.filter{ $0.matches(searchTerm: searchText) }
        self.tableView.reloadData()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        resultsArray = PostController.shared.posts
        tableView.reloadData()
        searchBar.text = ""
        resignFirstResponder()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearching = true
    }
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearching = false
    }
}

