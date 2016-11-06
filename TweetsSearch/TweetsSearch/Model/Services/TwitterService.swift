//
//  TwitterService.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/6/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import UIKit
import Accounts
import Social

typealias AccessSocialAccountHandler = (_ granted: Bool, _ error: TwitterServiceError) -> ()
typealias RequestTweetsHandler = (_ error: TwitterServiceError, _ tweets:AnyObject?) -> ()

enum TwitterServiceError{
    case NoError
    case AccessDenied
    case NoTwitterAccount
    case ConnectionError
}

class TwitterService: NSObject {
    
    private struct Constants{
        static let TwitterRESTURLString = "https://api.twitter.com/1.1/search/tweets.json"
        static let TweetsPageSize = 10
        
    }

    private let accountStore: ACAccountStore
    private let twitterAccountType: ACAccountType
    
    override init() {
        self.accountStore = ACAccountStore()
        self.twitterAccountType = self.accountStore.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)
    }
    
    func requestAccessToTwitterAccount(_ handler: @escaping AccessSocialAccountHandler){
        
        self.accountStore.requestAccessToAccounts(with: self.twitterAccountType, options: nil, completion: { (granted, error) in
            
            handler(granted, granted ? .NoError: .AccessDenied)
            
        })
    }
    
    func searchTweets(searchText q: String, handler: @escaping RequestTweetsHandler){
        if let account = self.accountStore.accounts(with: self.twitterAccountType).first as? ACAccount{
            let request = self.requestforSearchText(text: q)
            request.account = account
            request.perform(handler: { (data, response, error) in
                if error != nil || response?.statusCode != 200{
                    handler(.ConnectionError, nil)
                }
                else{
                    // We have good response now, let's try to parse it.
                }
            })
        }
        else{
            handler(.NoTwitterAccount, nil)
        }
    }
    
    private func requestforSearchText(text: String) -> SLRequest {
        let url = URL(string: Constants.TwitterRESTURLString)
        let params = [
            "q" : text,
            "count": "\(Constants.TweetsPageSize)"
        ]
        return SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: url, parameters: params)
    }
}
