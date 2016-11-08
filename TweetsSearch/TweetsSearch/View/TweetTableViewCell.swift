//
//  TweetTableViewCell.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/7/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import UIKit


@objc protocol TweetTableViewCellDelegate{
    func didClickOnTag(tag: String)
}

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetTextView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    private var viewModel: TweetCellViewModel? = nil
    weak var delegate: TweetTableViewCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.tweetTextView.delegate = self
    }
    
    func bindViewModel(viewModel: TweetCellViewModel){
        
        self.viewModel = viewModel
        
        // Binding goes here...
        _ = viewModel.username.observeNext(with: { (realName, screenName) in
            
            let name = NSMutableAttributedString(string: "\(realName) @\(screenName)")
            let range1 = NSMakeRange(0, realName.characters.count)
            name.addAttributes([
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 17)], range: range1)
            let range2 = NSMakeRange(range1.location + range1.length + 1, screenName.characters.count + 1)
            name.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 13)], range: range2)
            self.titleLabel.attributedText = name
        })
        _ = viewModel.tweetText.observeNext { (text) in

            self.styleMentionsAndHashTags()
            self.tweetTextView.sizeToFit()
        }
    }

    func styleMentionsAndHashTags(){
        if let viewModel = self.viewModel{
            let attributedText = NSMutableAttributedString(string: viewModel.tweetText.value)
            for (range, mention) in viewModel.metnionsInTweetText(){
                attributedText.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: range)
                attributedText.addAttributes([NSLinkAttributeName: "mention://\(mention)"], range: range)
            }
            
            for (range, hashtag) in viewModel.hashtagsInTweetText(){
                attributedText.addAttributes([NSForegroundColorAttributeName: UIColor.blue], range: range)
                attributedText.addAttributes([NSLinkAttributeName: "hashtag://\(hashtag)"], range: range)
            }
            
            self.tweetTextView.attributedText = attributedText
            
        }
    }
}

extension TweetTableViewCell: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    
        if URL.scheme == "mention"{
            //FIXME: We do nothing about mentions right now, We gonna handle it later :)
            return false
        }
        if URL.scheme == "hashtag" {
            
            /// Notify the delegate that a hashtag has been clicked to perform a search with that hashtag.
            self.delegate?.didClickOnTag(tag: URL.host ?? "")
            return false
        }
        return true // Let the system handles these kinds of urls :)
    }
}
