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
    }
    
    func bindViewModel(){
        self.viewModel.searchString.bidirectionalBind(to: self.searchTextField.bnd_text)
        self.viewModel.validSearchString
            .map{$0 ? UIColor.black : UIColor.red}
            .bind(to: self.searchTextField.bnd_textColor)
        self.viewModel.isSearching.bind(to: self.activityIndicator.bnd_animating)
    }
}
