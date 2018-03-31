//
//  LoadMoreCell.swift
//  NewsFeed
//
//  Created by Rohit Pal on 17/03/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit

class LoadMoreCell: UITableViewCell {
    @IBOutlet private weak var loadingMessageLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    func setupCell(loadMore: Bool) {
        if loadMore {
            activityIndicator.startAnimating()
            loadingMessageLabel.text = NSLocalizedString("Loading...", comment: "")
        } else {
            activityIndicator.stopAnimating()
            loadingMessageLabel.text = NSLocalizedString("That's all for Today!", comment: "")
        }
    }
}

extension LoadMoreCell: ReusableCell {
    static var ReuseIdentifier: String {
        return "LoadMoreCell"
    }

    static var NibName: String {
        return "LoadMoreCell"
    }

}

