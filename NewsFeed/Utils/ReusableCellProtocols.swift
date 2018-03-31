//
//  ReusableCellProtocols.swift
//  NewsFeed
//
//  Created by Rohit Pal on 17/03/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit

protocol NibLoadable {
    static var NibName: String { get }
}

extension NibLoadable {
    static func nib() -> UINib? {
        if !NibName.isEmpty {
            return UINib(nibName: NibName, bundle: nil)
        } else {
            return nil
        }
    }
}

protocol ReusableCell: NibLoadable {
    static var ReuseIdentifier: String { get }
}

extension ReusableCell where Self: UITableViewCell {
    static func registerNibForTable(_ table: UITableView) {
        if let nib = self.nib() {
            table.register(nib, forCellReuseIdentifier: self.ReuseIdentifier)
        }
    }
}

extension ReusableCell where Self: UITableViewHeaderFooterView {
    static func registerNibForTable(_ table: UITableView) {
        if let nib = self.nib() {
            table.register(nib, forHeaderFooterViewReuseIdentifier: self.ReuseIdentifier)
        }
    }
}

extension ReusableCell where Self: UICollectionViewCell {
    static func registerNibForCollection(_ collection: UICollectionView) {
        if let nib = self.nib() {
            collection.register(nib, forCellWithReuseIdentifier: self.ReuseIdentifier)
        }
    }
}

extension ReusableCell where Self: UICollectionReusableView {
    static func registerNibForCollection(_ collection: UICollectionView) {
        if let nib = self.nib() {
            collection.register(nib, forCellWithReuseIdentifier: self.ReuseIdentifier)
        }
    }
}

