//
//  NewsFeedController.swift
//  NewsFeed
//
//  Created by Rohit Pal on 17/03/18.
//  Copyright © 2018 Technobells. All rights reserved.
//

import UIKit
import RealmSwift

class NewsFeedController: UITableViewController {
    private var articles: Results<Article>!
    private var endOfList = false
    private var isLoadingData: Bool = false
    private var notificationToken: NotificationToken?
    private lazy var realm: Realm = {
        let realm = try! Realm()
        return realm
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataSource()
        setupTableView()
        addRefreshControl()
    }

    func setupDataSource() {
        articles = ArticleRepository.getCachedArticles(from: self.realm)
        // Add data source update notification
        notificationToken = articles.observe {[weak self] change in
            switch change {
            case .error(let error):
                self?.handleError(error: error)
            case .initial(_):
                self?.tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self?.applyChanges(inSection: 0, deletions: deletions, insertions: insertions, modifications: modifications)
            }
        }
    }

    func applyChanges(inSection section: Int, deletions: [Int], insertions: [Int], modifications: [Int]) {
        self.tableView.beginUpdates()
        self.tableView.deleteRows(at: deletions.map {IndexPath(row: $0, section: section)}, with: .top)
        self.tableView.insertRows(at: insertions.map {IndexPath(row: $0, section: section)}, with: .bottom)
        self.tableView.reloadRows(at: modifications.map {IndexPath(row: $0, section: section)}, with: .fade)
        self.tableView.endUpdates()
    }

    deinit {
        notificationToken?.invalidate()
    }

    func addRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        refreshControl?.tintColor = UIColor.gray
    }

    func setupTableView() {
        NewsFeedCell.registerNibForTable(self.tableView)
        LoadMoreCell.registerNibForTable(self.tableView)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160
    }

    func loadMoreArticles() {
        guard !isLoadingData && !endOfList else {
            return
        }
        isLoadingData = true
        ArticleRepository.loadMoreTechArticle(from: realm) { [weak self] errorT, result in
            DispatchQueue.main.async {
                if let error = errorT {// Handle error
                    self?.handleError(error: error)
                    self?.isLoadingData = false
                    self?.endOfList = true
                    return
                }
                if result?.count == 0 {// Handle the case of endof the list
                    self?.endOfList = true
                    self?.applyChanges(inSection: 1, deletions: [], insertions: [], modifications: [0])
                } else {
                    self?.endOfList = false
                }
                self?.isLoadingData = false
            }
        }
    }

    @objc func refreshData() {
        ArticleRepository.getFreshData(from: realm) { [weak self] errorT, result in
            DispatchQueue.main.async {
                self?.refreshControl?.endRefreshing()
                if let error = errorT {
                    self?.handleError(error: error)
                    return
                }
                if result?.count == 0 {
                    self?.endOfList = true
                    self?.applyChanges(inSection: 1, deletions: [], insertions: [], modifications: [0])
                } else {
                    self?.endOfList = false
                }
            }
        }
    }

    func handleError(error: Error) {
        let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? articles.count : 1
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if articles.count - indexPath.row <= 3 { //eager loading
            loadMoreArticles()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 { // show loading cell
            let cell = tableView.dequeueReusableCell(withIdentifier: LoadMoreCell.ReuseIdentifier, for: indexPath) as! LoadMoreCell
            cell.setupCell(loadMore: !endOfList)
            return cell
        }
        // show article cell
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsFeedCell.ReuseIdentifier, for: indexPath) as! NewsFeedCell
        let cellModel = NewsFeedCellModel(article: articles[indexPath.row])
        cell.setupCell(cellModel: cellModel)
        if let imageUrlString = cellModel.articleImageUrl {
            loadArticleImageInCell(at: indexPath, withUrlString: imageUrlString)
        }
        return cell
    }

    func loadArticleImageInCell(at indexPath: IndexPath, withUrlString urlString: String) {
        ImageLoader.shared.loadImage(from: urlString) {[weak self] imageUrlStringT, downloadedImage in
            DispatchQueue.main.async {
                let cell = self?.tableView.cellForRow(at: indexPath) as? NewsFeedCell
                cell?.setArticle(image: downloadedImage ?? #imageLiteral(resourceName: "placeholderImage"))
            }
        }
    }

}
