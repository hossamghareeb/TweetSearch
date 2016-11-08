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
import Argo

typealias AccessSocialAccountHandler = (_ granted: Bool, _ error: TwitterServiceError) -> ()
typealias RequestTweetsHandler = (_ error: TwitterServiceError, _ tweets:TweetsResponse?) -> ()

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
    
    func searchTweets(searchText q: String, readyQueryParamsString: String = "", handler: @escaping RequestTweetsHandler){
        if let account = self.accountStore.accounts(with: self.twitterAccountType).first as? ACAccount{
            let request = self.requestforSearchText(text: q, paramsString: readyQueryParamsString)
            request.account = account
            request.perform(handler: { (data, response, error) in
                if error != nil || response?.statusCode != 200{
                    print(error as Any)
                    handler(.ConnectionError, nil)
                }
                else{
                    // We have good response now, let's try to parse it.
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                        let str = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                        print(str as Any)
                        let tweetResponse: TweetsResponse? = decode(json)
                        handler(.NoError, tweetResponse)
                    }
                    else{
                        handler(.ConnectionError, nil)
                    }
                }
            })
        }
        else{
            handler(.NoTwitterAccount, nil)
        }
    }
    
    private func requestforSearchText(text: String, paramsString: String = "") -> SLRequest {
        let url = URL(string: Constants.TwitterRESTURLString + paramsString)
        var params = [AnyHashable: Any]()
        if paramsString != "" {
            let parts = paramsString.components(separatedBy: "&")
            for p in parts{
                let keyValue = p.components(separatedBy: "=")
                if keyValue.count == 2 {
                    params[keyValue[0]] = keyValue[1]
                }
            }
        }
        else{
            params = [
                "q" : text,
                "count": "\(Constants.TweetsPageSize)",
                "lang": "en"
            ]
        }
        
        return SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET, url: url, parameters: params)
    }
}
