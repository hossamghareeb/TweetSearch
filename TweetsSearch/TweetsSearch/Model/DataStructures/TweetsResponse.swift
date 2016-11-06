//
//  TweetsResponse.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/6/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import UIKit

struct TweetsResponse {
    let count: Int
    let query: String
    let nextResultsParamsString: String
    let tweets: [Tweet]
}


struct Tweet{
    let text: String
    let retweetCount: Int
    let id: String
}

struct User{
    let name: String
    let screenName: String
    let profileImageURLString: String
}
