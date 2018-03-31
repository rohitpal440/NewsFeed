//
//  ArticleRepository.swift
//  NewsFeed
//
//  Created by Rohit Pal on 17/03/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import Foundation
import RealmSwift   

class ArticleRepository {
    static func loadMoreTechArticle(from realm: Realm, completion: @escaping (_ error: Error?, _ articles: [Article]?) -> Void) {
        let page = getNextPage(from: realm)
        guard page.nextPage > page.currentPage else {
            completion(nil, [])
            return
        }
        API.getTopTechArticles(forPage: page.nextPage) { error, result in
            DispatchQueue.main.async {
                guard let jsonDict = result,
                    let articleContainer = ArticleContainer(json: jsonDict, page: page.nextPage) else {
                        completion(error, nil)
                        return
                }
                totalResults = articleContainer.totalArticles
                try! realm.write {
                    realm.add(articleContainer.articles)
                    completion(nil, articleContainer.articles)
                }
            }
        }
    }

    static private func getNextPage(from realm: Realm, forPageSize pageSize: Int = 5) -> (currentPage: Int, nextPage: Int) {
        let storedArticleCount = realm.objects(Article.self).count
        let q = storedArticleCount.quotientAndRemainder(dividingBy: pageSize).quotient
        if let totalAvailableResults = totalResults, totalAvailableResults <= q * pageSize || q * pageSize < storedArticleCount {
            return (q, q)
        }
        return (q, q + 1)
    }

    static func getCachedArticles(from realm: Realm) -> Results<Article> {
        return realm.objects(Article.self)
    }

    static func getFreshData(from realm: Realm, completion: @escaping (_ error: Error?, _ articles: [Article]?) -> Void) {
        let page = 1
        API.getTopTechArticles(forPage: page) { error, result in
            DispatchQueue.main.async {
                guard let jsonDict = result,
                    let articleContainer = ArticleContainer(json: jsonDict, page: page) else {
                        completion(error, nil)
                        return
                }
                totalResults = articleContainer.totalArticles
                try! realm.write {
                    realm.deleteAll()
                    realm.add(articleContainer.articles)
                    completion(nil, articleContainer.articles)
                }
            }
        }
    }

    static var totalResults: Int? {
        get {
            return UserDefaults.standard.object(forKey: "totalResult") as? Int
        }
        set {
            if let totolCount = totalResults {
                let defaults = UserDefaults.standard
                defaults.set(totolCount, forKey: "totalResult")
                defaults.synchronize()
            }
        }
    }
}
