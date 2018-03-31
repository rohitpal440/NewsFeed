//
//  API.swift
//  NewsFeed
//
//  Created by Rohit Pal on 17/03/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import Foundation

protocol APIProtocol {
    static func getTopTechArticles(forPage page: Int, pageSize size: Int, completion: @escaping (_ error: Error?, _ result: [String: Any]?) -> Void)
}

private let apiKey = "please_add_your_api_key"// replace the string with newsapi.org api key
private let baseURL = "newsapi.org"
private let apiVersion = "v2"
private let topHeadlinesPath = "top-headlines"
private let requestTimeout: TimeInterval = 30
class API: APIProtocol {
    static func getTopTechArticles(forPage page: Int, pageSize size: Int = 5, completion: @escaping (_ error: Error?, _ result: [String: Any]?) -> Void) {
        // Build url
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "country", value: "us"),
            URLQueryItem(name: "category", value: "technology"),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "pageSize", value: size.description),
            URLQueryItem(name: "page", value: page.description)
        ]
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = baseURL
        urlComponent.path = "/" + apiVersion.appendingFormat("/%@", topHeadlinesPath)
        urlComponent.queryItems = queryItems
        guard let url = urlComponent.url else {
            completion(NSError(domain: "Invalid URL", code: 100, userInfo: ["message": NSLocalizedString("Something went wrong", comment: "")]), nil)
            return
        }
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: requestTimeout)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-type")
        // make get request
        let task = URLSession.shared.dataTask(with: request) { downloadedData, response, errorT in
            if let error = errorT {
                completion(error, nil)
                return
            }
            guard let data = downloadedData else {
                completion(NSError(domain: "Network", code: 100, userInfo: [NSLocalizedDescriptionKey: "Network request returned no data"]), nil)
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                guard let jsonDict = json as? [String: Any] else {
                    completion(NSError(domain: "Unable to parse response", code: 100, userInfo: ["message": NSLocalizedString("Something went wrong", comment: "")]), nil)
                    return
                }
                completion(nil, jsonDict)
            } catch {
                completion(error, nil)
            }
        }
        task.resume()
    }
}
