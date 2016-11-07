//
//  TweetSearchViewController.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/4/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit
import DZNEmptyDataSet

class TweetSearchViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tweetsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    let viewModel = TweetSearchViewModel()
    
    var text: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindViewModel()
        
        self.tweetsTableView.dataSource = self
        self.tweetsTableView.emptyDataSetSource = self
        self.tweetsTableView.emptyDataSetDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.viewModel.requestAccessToTwitterAccount()
    }
    
    // MARK: - View Model Binding -

    
    func bindViewModel(){
        self.viewModel.searchString.bidirectionalBind(to: self.searchTextField.bnd_text)
        self.viewModel.validSearchString
            .map{$0 ? UIColor.black : UIColor.red}
            .bind(to: self.searchTextField.bnd_textColor)
        self.viewModel.isSearching.bind(to: self.activityIndicator.bnd_animating)
        _ = self.viewModel.twitterServiceError.observeNext { (error) in
            self.tweetsTableView.reloadData()
        }
        _ = self.viewModel.items.observeNext(with: { (e) in
            self.tweetsTableView.reloadData()
        })
    }
}

// MARK: - UITableViewDataSource -


extension TweetSearchViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TweetTableViewCell
        if let vm = self.viewModel.viewModelForTweetAtIndex(index: indexPath.row) {
            cell.bindViewModel(viewModel: vm)
        }
        return cell
    }
}

// MARK: - DZNEmptyDataSetSource -

extension TweetSearchViewController: DZNEmptyDataSetSource{
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!{
        var title = ""
        switch self.viewModel.twitterServiceError.value {
        case .AccessDenied:
            title = "Access Denied!"
        case .NoTwitterAccount:
            title = "No Twitter Account!"
        case .ConnectionError:
            title = "Connection Error!"
        default:
            title = "No Tweets!"
        }
        return NSAttributedString(string: title)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString!{
        var description = ""
        switch self.viewModel.twitterServiceError.value {
        case .AccessDenied:
            description = "You didn't grant us access to Twitter accounts. Please go to Settings to change permissions."
        case .NoTwitterAccount:
            description = "No Twitter accounts has been found. Kindly visit Settings to setup a Twitter account and try again."
        case .ConnectionError:
            description = "An error has been occured while connection to Twitter server to fetch data."
        default:
            description = "No available Tweets. Do some search or check your search criteria."
        }
        return NSAttributedString(string: description)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        let error = self.viewModel.twitterServiceError.value
        if error == .AccessDenied || error == .NoTwitterAccount {
            return NSAttributedString(string: "Open App Settings")
        }
        return nil
    }
}

// MARK: - DZNEmptyDataSetDelegate -

extension TweetSearchViewController: DZNEmptyDataSetDelegate{
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        if let settingsURL = URL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
        }
    }
}
