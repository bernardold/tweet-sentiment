//
//  CoordinatorHolderView.swift
//  tweet-sentiment
//
//  Created by Bernardo Duarte on 12/01/19.
//  Copyright © 2019 Bernardo Duarte. All rights reserved.
//

import UIKit

protocol CoordinatorHolderView: class {
    var coordinator: Coordinator? { get set }
}