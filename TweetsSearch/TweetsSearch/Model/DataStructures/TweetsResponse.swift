//
//  TweetsResponse.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/6/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import Argo
import Curry
import Runes

struct TweetsResponse {
    let count: Int
    let query: String
    let nextResultsParamsString: String?
    let refreshResultsParamsString: String?
    let tweets: [Tweet]
}

extension TweetsResponse: Decodable {
    static func decode(_ j: JSON) -> Decoded<TweetsResponse> {
        return curry(TweetsResponse.init)
            <^> j <| ["search_metadata", "count"]
            <*> j <| ["search_metadata", "query"]
            <*> j <|? ["search_metadata", "next_results"]
            <*> j <|? ["search_metadata", "refresh_url"]
            <*> j <|| "statuses" // parse arrays of objects
    }
}


struct Tweet{
    let text: String
    let retweetCount: Int
    let id: String
    let user: User
}

extension Tweet: Decodable{
    static func decode(_ j: JSON) -> Decoded<Tweet> {
        return curry(Tweet.init)
            <^> j <| "text"
            <*> j <| "retweet_count"
            <*> j <| "id_str"
            <*> j <| "user" // parse arrays of objects
    }
}

struct User{
    let name: String
    let screenName: String
    let profileImageURLString: String
}

extension User: Decodable{
    static func decode(_ j: JSON) -> Decoded<User> {
        return curry(User.init)
            <^> j <| "name"
            <*> j <| "screen_name"
            <*> j <| "profile_image_url"
    }
}
