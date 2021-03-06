//
//  TwitterRepository.swift
//  tweet-sentiment
//
//  Created by Bernardo Duarte on 12/01/19.
//  Copyright © 2019 Bernardo Duarte. All rights reserved.
//

import Foundation
import Domain
import RxSwift
import Moya

struct TwitterRepository: TwitterDataRepository {
    private let twitterRemoteDataSource: TwitterRemoteDataSource

    public init(twitterRemoteDataSource: TwitterRemoteDataSource) {
        self.twitterRemoteDataSource = twitterRemoteDataSource
    }

    func getBearerToken() -> Single<BearerToken> {
        /* TODO: Improvement: Have a MemoryDataSource to save the bearer token in memory
                 to prevent from calling service everytime */
        return twitterRemoteDataSource.getBearerToken().map({ $0.toDomainModel() })
    }

    func searchUser(handle: String) -> Single<TwitterUser> {
        return self.getBearerToken()
            .flatMap { bearerToken in
                return self.twitterRemoteDataSource.searchUser(handle: handle, authorization: bearerToken.value)
                    .map({ $0.toDomainModel() })
            }
    }

    func getTweets(handle: String, maxId: String?) -> Single<[Tweet]> {
        return self.getBearerToken()
            .flatMap { bearerToken in
                return self.twitterRemoteDataSource.getTweets(handle: handle, maxId: maxId, authorization: bearerToken.value)
                    .map({ $0.toDomainModel() })
        }
    }
}
