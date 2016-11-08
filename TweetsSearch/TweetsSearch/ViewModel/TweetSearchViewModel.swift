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
    
    /// flas indicates whether searching is still in progress or not. Views can observe this value to display actitivy indicator.
    let isSearching = Observable<Bool>(false)
    
    /// Twitte service model that takes care of all server operations.
    private let twitterService: TwitterService = TwitterService()
    
    /// The current error we have while trying to access tweets and search.
    let twitterServiceError = Observable(TwitterServiceError.NoError)
    
    /// The current list of tweets we have on the screen
    var items = [Tweet]()
    
    /// Trigger after list of tweets get changed. Views can observe this value to reload the list of tweets.
    let tweetsHasChanged = Observable<Bool>(false)
    
    /// flag indicates whether we have more pages to load or not. Views can check this value before calling for next page.
    var hasMorePages = false
    
    /// its true as long as we're requesting next page. Can be used to stop fetching next page if we already fetching it.
    private var isRequestingNextPage = false
    
    /// The last tweet response we got from server. We keep as it has information about the query, refresh url,...etc.
    private var currentTweetResponse: TweetsResponse?
    
    /// Refreshing
    
    /// The available refresh intervals in seconds.
    private let refreshIntervals = [0, 2, 5, 30, 60]
    /// The user friendly refresh intervals to be displayed to user to select from.
    let refreshIntervalStrings = ["No Refresh", "2 Seconds", "5 Seconds", "30 Seconds", "1 Minute"]
    
    /// The current auto refresh interval index.
    var currentIntervalSelection = 2{
        didSet{
            setupTimeForAutoRefresh()
        }
    }
    
    /// Current scheduled timer to auto refresh.
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
    
    /// Setup a new timer to auto call the refresh function based on the selected interval. If there is any current timer schedulted before, it will be invalidated.
    private func setupTimeForAutoRefresh(){
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
    
    /// Ask user permission to access Twitter account from settings.
    func requestAccessToTwitterAccount(){
        self.twitterService.requestAccessToTwitterAccount { (granted, error) in
            DispatchQueue.main.async {
                self.twitterServiceError.value = error
            }
        }
    }
    
    /// Get the view model for the tweet at given index. 
    /// - Parameter index: The index of the tweet that you need a view model for it. 
    /// - Returns: a view model for the tweet at the given index OR **nil** if there is not tweet at the given index.
    func viewModelForTweetAtIndex(index: Int) -> TweetCellViewModel?{
        if index >= 0 && index < self.items.count {
            let tweet = self.items[index]
            let viewModel = TweetCellViewModel(tweet: tweet)
            return viewModel
        }
        return nil
    }
    
    /// Ask the service to load the next page of tweets.
    func requestNextPageOfTweets(){
        if let response = currentTweetResponse{
            if isRequestingNextPage {
                return
            }
            self.isRequestingNextPage = true
            startTweetSearching(searchText: response.query, preReadyParams: response.nextResultsParamsString ?? "")
        }
    }
    
    /// Refresh the tweets
    @objc func refreshCurrentTweet(){
        if let response = currentTweetResponse{
            startTweetSearching(searchText: response.query, preReadyParams: response.refreshResultsParamsString ?? "")
        }
    }
    
    /// Send API call to start searching for tweets with the query and any parameters we have. 
    private func startTweetSearching(searchText text: String, preReadyParams: String = ""){
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
                self.tweetsHasChanged.value = true
            }
        })
    }
}
