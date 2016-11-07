//
//  TweetTableViewCell.swift
//  TweetsSearch
//
//  Created by Hossam Ghareeb on 11/7/16.
//  Copyright © 2016 Hossam Ghareeb. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {

    private var viewModel: TweetCellViewModel? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindViewModel(viewModel: TweetCellViewModel){
        
        // Binding goes here...
       
        _ = viewModel.username.observeNext(with: { (realName, screenName) in
            
            let name = NSMutableAttributedString(string: "\(realName) @\(screenName)")
            let range1 = NSMakeRange(0, realName.characters.count)
            name.addAttributes([
                NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)], range: range1)
            let range2 = NSMakeRange(range1.location + range1.length + 1, screenName.characters.count + 1)
            name.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 10)], range: range2)
            self.textLabel?.attributedText = name
        })
        if let detailsLabel = self.detailTextLabel{
            viewModel.tweetText.bind(to: detailsLabel)
        }
        
        
        self.viewModel = viewModel
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
