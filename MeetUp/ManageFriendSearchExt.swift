//
//  ExtManageFriend.swift
//  MeetUp
//
//  Created by Chris Duan on 13/07/16.
//  Copyright © 2016 Chris. All rights reserved.
//

import UIKit

private var searchView: SearchView!
private var searchController = UISearchController(searchResultsController: nil)

extension ManageFriendViewController: UISearchResultsUpdating, UISearchBarDelegate, SearchFriendListener, AddFriendListener, SearchViewDelegate {

    func setupSearchController() {
        searchView = NibLoader.sharedInstance.loadNibWithName("SearchView", owner: nil, ofclass: SearchView.self) as! SearchView
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let phoneNumber = searchController.searchBar.text where phoneNumber.characters.count > 6 {
            //search
            searchView.startActivityIndicator()
            searchFriendMode.searchFriendByPhoneNumber(phoneNumber)
        }
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.addSearchTableView()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        removeSearchView()
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        removeSearchView()
    }
    
    private func removeSearchView() {
        searchView.removeFromSuperview()
        searchView.setDelegate(nil)
    }
    
    private func addSearchTableView() {
        let headerRect = tableView.tableHeaderView!.frame
        let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let headerHeight = tableView.tableHeaderView!.frame.size.height
        searchView.frame = CGRect(x: 0, y: headerHeight + statusBarHeight, width: headerRect.size.width, height: self.view.frame.size.height)
        
        searchView.alpha = 0.0
        self.view.addSubview(searchView);
        UIView.animateWithDuration(0.5, animations: {
            searchView.alpha = 1.0
            }, completion: nil);
        
        searchView.setDelegate(self)
    }
    
    //MARK: VIEW CALLBACK
    func addFriend(user: User) {
        addFriendModel.requestAddFriend(user)
    }
    
    //MARK: MODEL CALLBACK
    func onSearchResult(users: [UserFromSearch]) {
        searchView.setTableData(users)
    }
    
    func onSearchFailed() {
        searchView.setTableData([])
    }
    
    func onAddFriendSuccessful() {
        searchView.requestFinished(isSuccessful: true)
    }
    
    func onAddFriendFailed(message: String) {
        onError(message)
        searchView.requestFinished(isSuccessful: false)
    }
}