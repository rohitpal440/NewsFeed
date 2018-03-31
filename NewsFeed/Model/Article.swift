//
//  Article.swift
//  NewsFeed
//
//  Created by Rohit Pal on 17/03/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import Foundation
import RealmSwift

struct ArticleContainer {
    var articles: [Article] = []
    let page: Int
    let totalArticles: Int

    init?(json: [String: Any], page: Int) {
        guard let articlesT = json["articles"] as? [[String: Any]], let totalArticles = json["totalResults"] as? Int else {
            return nil
        }
        self.page = page
        self.totalArticles = totalArticles
        for article in articlesT {
            let source = article["source"] as? [String: String]
            let sourceName = source?["name"] ?? ""
            // parse date
            let date = article["publishedAt"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            articles.append(Article(value: [
                "title": article["title"] as? String ?? "",
                "articleUrl": article["url"] as? String ?? "",
                "sorceName": sourceName,
                "imageUrl": article["urlToImage"],
                "articleDescription": article["description"] ,
                "author": article["author"],
                "publishedAt": dateFormatter.date(from: date) ?? Date()
                ]))
        }
    }
}

final class Article: Object {
    @objc dynamic var title = ""
    @objc dynamic var articleUrl = ""
    @objc dynamic var sourceName = ""
    @objc dynamic var imageUrl: String? = nil
    @objc dynamic var articleDescription: String? = nil
    @objc dynamic var author: String? = nil
    @objc dynamic var publishedAt = Date()
}
