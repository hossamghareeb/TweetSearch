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
    
    func metnionsInTweetText() -> [(range: NSRange, mention: String)]{
        
        return matchesForPattern(pattern: "@(\\w+)", inText: self.tweet.text)
    }
    
    func hashtagsInTweetText() -> [(range: NSRange, tag: String)]{
        
        return matchesForPattern(pattern: "#(\\w+)", inText: self.tweet.text)
    }
    
     func matchesForPattern(pattern: String, inText text: String) ->  [(NSRange, String)]{
        
        do{
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: text, options: NSRegularExpression.MatchingOptions.withTransparentBounds, range: NSMakeRange(0, text.characters.count)
            )
            var mentions = [(range: NSRange, mention: String)]()
            for match in matches{
                let range = match.range
                var wordRange = range
                wordRange.location += 1
                wordRange.length -= 1
                let mention = (text as NSString).substring(with: wordRange)
                mentions.append((range, mention))
            }
            
            return mentions
        }catch{
            return []
        }
    }
}
