//
//  UICollectionView+Extensions.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 28/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

extension Collection where Element == NSLayoutConstraint {

    func active() {
        forEach { $0.isActive = true }
    }
}
