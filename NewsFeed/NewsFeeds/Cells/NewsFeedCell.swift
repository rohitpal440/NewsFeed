//
//  NewsFeedCell.swift
//  NewsFeed
//
//  Created by Rohit Pal on 17/03/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit
import RealmSwift

protocol NewsFeedCellProtocol {
    var articleTitle: String { get }
    var articleDescriptionWithLink: String { get }
    var articleImageUrl: String? { get }
}

struct NewsFeedCellModel: NewsFeedCellProtocol {
    private var model: Article

    init(article: Article) {
        model = article
    }

    var articleDescriptionWithLink: String {
        if let articleDescription =  model.articleDescription {
            return "\(articleDescription)\n\(model.articleUrl)"
        }
        return "\(model.articleUrl)"
    }

    var articleImageUrl: String? {
        return model.imageUrl
    }

    var articleTitle: String {
        return model.title
    }
}

class NewsFeedCell: UITableViewCell {
    @IBOutlet private weak var articleImage: UIImageView!
    @IBOutlet private weak var articleDescriptionView: UITextView!
    @IBOutlet private weak var articleTitle: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    func setupCell(cellModel: NewsFeedCellProtocol) {
        articleImage.image = #imageLiteral(resourceName: "placeholderImage")
        articleTitle.text = cellModel.articleTitle
        articleDescriptionView.text = cellModel.articleDescriptionWithLink
        if cellModel.articleImageUrl != nil {
            activityIndicator.startAnimating()
        }
    }

    func setArticle(image: UIImage) {
        self.articleImage.image = image
        activityIndicator.stopAnimating()
    }
}

extension NewsFeedCell: ReusableCell {
    static var ReuseIdentifier: String {
        return "NewsFeedCell"
    }

    static var NibName: String {
        return "NewsFeedCell"
    }

}
