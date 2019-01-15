//
//  TweetsViewController.swift
//  tweet-sentiment
//
//  Created by Bernardo Duarte on 13/01/19.
//  Copyright © 2019 Bernardo Duarte. All rights reserved.
//

import UIKit
import RxSwift

protocol TweetsView: CoordinatorHolderView {
    var tweetSelected: PublishSubject<TweetsViewModel.Tweet> { get }
    func displayTweets(_ tweets: [TweetsViewModel.Tweet], done: Bool)
}

class TweetsViewController: UIViewController {
    weak var coordinator: Coordinator?
    let disposeBag = DisposeBag()
    var presenter: TweetsPresenter!

    var selectedUser: UserSearchViewModel.User?
    var dataSource = [TweetsViewModel.Tweet]()
    var hasMore: Bool!

    var tweetSelected = PublishSubject<TweetsViewModel.Tweet>()

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupObservables()
        presenter.askForTweets(fromUserHandle: selectedUser?.handle ?? "")
    }
}

extension TweetsViewController {
    fileprivate func setupView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(TweetTableViewCell.nib, forCellReuseIdentifier: TweetTableViewCell.identifier)
        hasMore = true
    }

    fileprivate func setupObservables() {
        tableView.rx.itemSelected.asObservable()
            .do(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .map({ [weak self] indexPath in
                guard let self = self else { throw NSError() }
                return self.dataSource[indexPath.row]
            })
            .bind(to: tweetSelected)
            .disposed(by: disposeBag)

        tableView.rx.willDisplayCell.asObservable()
            .filter({ [weak self] (_, indexPath) in
                guard let self = self else { return false }
                return (self.hasMore && indexPath.row == self.dataSource.count - 1)
            })
            .map { [weak self] (_, indexPath) -> String in
                guard let self = self else { return "" }
                return self.dataSource[indexPath.row].tweetId
            }
            .subscribe(onNext: { [weak self] lastTweetId in
                self?.presenter.askForTweets(fromUserHandle: self?.selectedUser?.handle ?? "",
                                            lastTweetId: lastTweetId)
            })
            .disposed(by: disposeBag)
    }
}

extension TweetsViewController: TweetsView {
    func displayTweets(_ tweets: [TweetsViewModel.Tweet], done: Bool) {
        hasMore = !done
        dataSource.append(contentsOf: tweets)
        tableView.reloadData()
    }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier) as? TweetTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(withTweet: dataSource[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
}