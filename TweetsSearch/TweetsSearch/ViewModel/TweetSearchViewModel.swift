//
//  TweetSearchViewModel.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/4/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import UIKit
import Bond
import ReactiveKit

class TweetSearchViewModel {
    
    private struct Constants{
        static let MinimumSearchLength = 3
        static let SearchThrottleTimeInSeconds: TimeInterval = 0.5
    }

    let searchString = Observable<String?>("")
    let validSearchString = Observable<Bool>(false)
    let isSearching = Observable<Bool>(false)
    let twitterService: TwitterService = TwitterService()
    let twitterServiceError = Observable(TwitterServiceError.NoError)
    
    let items = MutableObservableArray<Tweet>([])
    
    init() {
        searchString.value = "" // default value in text field of search

        searchString
            .map { $0!.characters.count > Constants.MinimumSearchLength }
            .bind(to: validSearchString)
        _ = searchString
            .filter{$0!.characters.count > Constants.MinimumSearchLength }
            .throttle(seconds: Constants.SearchThrottleTimeInSeconds)
            .observeNext{ [unowned self] text in
                self.startTweetSearching(searchText: text!)
        }
    }
    
    func requestAccessToTwitterAccount(){
        self.twitterService.requestAccessToTwitterAccount { (granted, error) in
            DispatchQueue.main.async {
                self.twitterServiceError.value = error
            }
        }
    }
    
    func viewModelForTweetAtIndex(index: Int) -> TweetCellViewModel?{
        if index >= 0 && index < self.items.count {
            let tweet = self.items[index]
            let viewModel = TweetCellViewModel(tweet: tweet)
            return viewModel
        }
        return nil
    }
    
    func startTweetSearching(searchText text: String){
        print(text)
        if self.twitterServiceError.value == .AccessDenied {
            return
        }
        self.isSearching.value = true
        self.twitterService.searchTweets(searchText: text, handler: { (error, tweetResponse) in
            DispatchQueue.main.async {
                self.twitterServiceError.value = error
                self.isSearching.value = false
                
                if error == .NoError{
                    self.items.removeAll()
                    if let response = tweetResponse{
                        self.items.insert(contentsOf: response.tweets, at: 0)
                    }
                }
                
            }
            
        })
    }
}
