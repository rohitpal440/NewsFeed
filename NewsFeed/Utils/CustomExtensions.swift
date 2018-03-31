//
//  CustomExtensions.swift
//  NewsFeed
//
//  Created by Rohit Pal on 17/03/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit

extension UIImageView {
    // Asynchronously load image
    func loadImage(from url: String, withPlaceholder placeholder: UIImage? = nil, completion: @escaping (_ downLoadedImage: UIImage?) -> Void) {
        self.image = placeholder
        ImageLoader.shared.loadImage(from: url) {[weak self] givenUrl, downLoadedImage in
            DispatchQueue.main.async {
                if let image = downLoadedImage {
                    self?.image = image
                } else {
                    self?.image = placeholder
                }
                completion(downLoadedImage)
            }
        }
    }
}

class ImageLoader {
    static let shared: ImageLoader = ImageLoader()
    private var imageCache: NSCache<NSURL, UIImage> = NSCache()
    private init(){}
    func loadImage(from url: String, completion: ((String, UIImage?) -> Void)?) {
        guard let imageUrl = URL(string: url) else {
            completion?(url, nil)
            return
        }
        if let cachedImage = imageCache.object(forKey: imageUrl as NSURL), let cgImage = cachedImage.cgImage  {
            let newImage = UIImage(cgImage: cgImage)
            completion?(url, newImage)
            return
        }
        let task = URLSession.shared.dataTask(with: imageUrl) { dataT, _, error in
            guard let data = dataT, let img = UIImage(data: data), error == nil else {
                completion?(url, nil)
                return
            }
            self.imageCache.setObject(img, forKey: imageUrl as NSURL)
            let newImage = UIImage(data: data)
            completion?(url, newImage)
        }
        task.resume()
    }
}

