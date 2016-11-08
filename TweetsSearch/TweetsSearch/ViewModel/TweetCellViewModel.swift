//
//  TweetCellViewModel.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/7/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import UIKit
import Bond

/// The view model for the tweet cell view.
class TweetCellViewModel: NSObject {

    /// The tweet model object specified for the current view model.
    private let tweet: Tweet
    
    /// Observable property for the username of the user who tweeted this tweet. Views should listen to it to update the UI once this property changes.
    let username = Observable<(realName: String, screenName: String)>(("", ""))
    
    /// Observable property for the tweet text of the tweet. Views should listen to it to update the UI once this property changes.
    let tweetText = Observable<String>("")
    
    /// Observable property for the retweet count of the tweet. Views should listen to it to update the UI once this property changes.
    let tweetCount = Observable<Int>(0)
    
    /// initialize the view model using the Tweet model object.
    init(tweet: Tweet) {
        self.tweet = tweet
        self.username.value = (realName: tweet.user.name, screenName: tweet.user.screenName)
        
        self.tweetText.value = tweet.text
        
        self.tweetCount.value = tweet.retweetCount
    }
    
    /**
     Detect all mentions (for example @barcelona ) in the current tweet text. 
     - Returns: Array of tuples where each tuple has a range (location and length) of the mention and the mention text itself.
     */
    func metnionsInTweetText() -> [(range: NSRange, mention: String)]{
        
        return matchesForPattern(pattern: "@(\\w+)", inText: self.tweet.text)
    }
    
    /**
     Detect all hashtags (for example #barcelona) in the current tweet text.
     - Returns: Array of tuples where each tuple has a range (location and length) of the hashtag and the hashtag text itself.
     */
    func hashtagsInTweetText() -> [(range: NSRange, tag: String)]{
        
        return matchesForPattern(pattern: "#(\\w+)", inText: self.tweet.text)
    }
    
    /**
     Detect all sub strings that match a given pattern (regular expression) in a given text.
     - Parameter pattern: The regular expression used in searching for substrings that match this expression. 
     - Parameter text: The text that we gonna search in. 
     - Returns: Array of all matches in the given string. Each item is a tuple which has a range of the match and the matched text itself.
     */
    
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
