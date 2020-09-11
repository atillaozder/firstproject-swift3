//
//  FriendsTableVC.swift
//  FirstProject
//
//  Created by FirstProject on 13.09.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit

final class FriendsTableVC: UITableViewController, ErrorHandling {
    
    // MARK: - Properties
    
    weak var personDelegate: PersonDelegate?
    fileprivate var currentPerson: Person? {
        didSet {
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    var personHolder: Person {
        get { return self.currentPerson! }
        set { currentPerson = newValue }
    }
    
    fileprivate var filteredFriend = [Person]()
    fileprivate var searchController: UISearchController = UISearchController(searchResultsController: nil)
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }
    
    // MARK: - View Methods
    
    private func setupViews() {
        // Table View
        tableView.register(UINib(nibName: "FriendsTableCell", bundle: nil), forCellReuseIdentifier: "FriendsTCell")
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.tableFooterView = UIView()
        
        // Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        definesPresentationContext = true
        
        // Search Bar
        searchController.searchBar.placeholder = "Ara..."
        searchController.searchBar.setValue("Vazgeç", forKey: "_cancelButtonText")
        searchController.searchBar.sizeToFit()
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.delegate = self
        searchController.delegate = self
        
        self.navigationItem.titleView = searchController.searchBar
        tableView.reloadData()
    }
    
    // MARK: - Action Methods
    
    @IBAction func handleRefreshing(_ sender: UIRefreshControl) {
        _ = NetworkManager.sharedManager.getRequest().subscribe(onNext: { person in
            
            self.personHolder = person!
            self.personDelegate?.didUpdate(currentPerson: self.personHolder, fromVC: self)
            
        }, onError: { error in
            
            self.handle(error: error)
            self.refreshControl?.endRefreshing()
            
        }, onCompleted: {
            
            self.refreshControl?.endRefreshing()
            
        },onDisposed: { })
    }
    
    // MARK: - Helpers
    
    fileprivate func filterContentForSearchText(searchText: String, scope: String = "All") {
        guard currentPerson != nil else { return }
        filteredFriend = currentPerson!.getFriends().filter { filtered in
            return filtered.username.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
    
    fileprivate func deleteFriend(fromIndex index: Int) {
        guard let friend = currentPerson?.getFriends()[index] else { return }
        let deleteURL = "\(currentPerson!.id)&friend=\(friend.id)"
        
        _ = NetworkManager.sharedManager.deleteRequest(URL: deleteURL).subscribe(onNext: { success in
            
        }, onError: { (error) in
            
            self.handle(error: error)
            
        }, onCompleted: {
            
            self.personHolder.removeFriend(at: index)
            self.personDelegate?.didUpdate(currentPerson: self.personHolder, fromVC: self)
            self.tableView.reloadData()
            
        }, onDisposed: {})
    }
    
    fileprivate func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    fileprivate func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

// MARK: - Table View Data Source

extension FriendsTableVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard currentPerson != nil else { return 0 }
        
        if isFiltering() {
            return filteredFriend.count
        }
        
        return currentPerson!.getFriends().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier: String = "FriendsTCell"
        let cell: FriendsTCell = self.tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FriendsTCell
        
        if isFiltering() {
            
            cell.usernameLbl.text = filteredFriend[indexPath.row].username
            
        } else {
            
            if let friends = currentPerson?.getFriends() {
                cell.configureCell(withFriend: friends[indexPath.row])
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

// MARK: - Table View Delegate

extension FriendsTableVC {
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let friendsCell = self.tableView.dequeueReusableCell(withIdentifier: "FriendsTCell", for: indexPath) as! FriendsTCell
        let leftInset = friendsCell.getLeftInsets()
        
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
        }
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76.0
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Sil") { (action, indexPath) in
            self.deleteFriend(fromIndex: indexPath.row)
        }
        delete.backgroundColor = UIColor.createColorWithRGB(r: 255.0, g: 64.0, b: 64.0)
        return [delete]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: FriendsTCell = tableView.cellForRow(at: indexPath) as! FriendsTCell
        guard let text = cell.usernameLbl.text else { return }
        self.navigationItem.title = text
        
        let chatVC = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        chatVC.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(chatVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - Search Results Updating

extension FriendsTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

// MARK: - Search Controller Delegate

extension FriendsTableVC: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Search Bar Delegate

extension FriendsTableVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}



