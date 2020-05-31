//
//  Int+Extensions.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 29/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit
import CoreMedia

extension Int {
    var cgFloat: CGFloat { CGFloat(self) }

    var isOdd: Bool { self % 2 == 0 }
}
