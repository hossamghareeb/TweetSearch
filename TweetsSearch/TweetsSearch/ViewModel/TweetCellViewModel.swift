//
//  TweetCellViewModel.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/7/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import UIKit
import Bond

class TweetCellViewModel: NSObject {

    private let tweet: Tweet
    
    let username = Observable<(realName: String, screenName: String)>(("", ""))
    let tweetText = Observable<String>("")
    
    init(tweet: Tweet) {
        self.tweet = tweet
        self.username.value = (realName: tweet.user.name, screenName: tweet.user.screenName)
        
        self.tweetText.value = tweet.text
    }
}