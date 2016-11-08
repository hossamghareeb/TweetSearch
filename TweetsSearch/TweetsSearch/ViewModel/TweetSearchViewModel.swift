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

/// The view model for the Tweet searching view
class TweetSearchViewModel {
    
    /// Constants related to tweet searching
    private struct Constants{
        
        /// The minimum length required for the search text to perform search.
        static let MinimumSearchLength = 3
        
        /// The throttle time between successive searches.
        static let SearchThrottleTimeInSeconds: TimeInterval = 0.5
    }

    /// Obserable property for the current search string.
    let searchString = Observable<String?>("")
    
    /// flag indicates whether the current search string is valid or not.
    let validSearchString = Observable<Bool>(false)
    
    
    let isSearching = Observable<Bool>(false)
    let twitterService: TwitterService = TwitterService()
    let twitterServiceError = Observable(TwitterServiceError.NoError)
    
    let items = MutableObservableArray<Tweet>([])
    
    var hasMorePages = false
    
    private var isRequestingNextPage = false
    
    private var currentTweetResponse: TweetsResponse?
    
    /// Refreshing
    let refreshIntervals = [0, 2, 5, 30, 60]
    let refreshIntervalStrings = ["No Refresh", "2 Seconds", "5 Seconds", "30 Seconds", "1 Minute"]
    var currentIntervalSelection = 3{
        didSet{
            setupTimeForAutoRefresh()
        }
    }
    
    private var currentTimer: Timer? = nil
    
    init() {
        searchString.value = "" // default value in text field of search

        searchString
            .map { $0!.characters.count > Constants.MinimumSearchLength }
            .bind(to: validSearchString)
        _ = searchString
            .filter{$0!.characters.count > Constants.MinimumSearchLength }
            .throttle(seconds: Constants.SearchThrottleTimeInSeconds)
            .observeNext{ [unowned self] text in
                if let response = self.currentTweetResponse{
                    if response.query == text{
                        return
                    }
                }
                self.startTweetSearching(searchText: text!)
        }
        
        setupTimeForAutoRefresh()
    }
    
    func setupTimeForAutoRefresh(){
        if let timer = self.currentTimer{
            timer.invalidate()
            self.currentTimer = nil
        }
        let i = self.currentIntervalSelection
        let interval = (i >= 0 && i < self.refreshIntervals.count) ? refreshIntervals[i] : 0
        if interval == 0 {
            return
        }
        
        self.currentTimer = Timer.scheduledTimer(timeInterval: TimeInterval(interval), target: self, selector: #selector(TweetSearchViewModel.refreshCurrentTweet), userInfo: nil, repeats: true)
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
    
    func requestNextPageOfTweets(){
        if let response = currentTweetResponse{
            if isRequestingNextPage {
                return
            }
            self.isRequestingNextPage = true
            startTweetSearching(searchText: response.query, preReadyParams: response.nextResultsParamsString ?? "")
        }
    }
    
    @objc func refreshCurrentTweet(){
        if let response = currentTweetResponse{
            startTweetSearching(searchText: response.query, preReadyParams: response.refreshResultsParamsString ?? "")
        }
    }
    
    func startTweetSearching(searchText text: String, preReadyParams: String = ""){
        print(text)
        if self.twitterServiceError.value == .AccessDenied {
            return
        }
        self.isSearching.value = true
        
        self.twitterService.searchTweets(searchText: text, readyQueryParamsString: preReadyParams, handler: {(error, tweetResponse) in
        
            DispatchQueue.main.async {
                self.twitterServiceError.value = error
                self.isSearching.value = false
                if error == .NoError{
                    if(!self.isRequestingNextPage){
                        self.items.removeAll()
                    }
                    if let response = tweetResponse{
                        self.currentTweetResponse = response
                        self.hasMorePages = response.nextResultsParamsString != nil
                        self.items.insert(contentsOf: response.tweets, at: self.items.count)
                        
                    }
                }
                
                self.isRequestingNextPage = false
                
            }
        })
    }
}
