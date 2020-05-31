//
//  Font+Extension.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 31/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {

    static func postGrotestBold(_ size: CGFloat) -> UIFont? {
        if let font = UIFont(name: "PostGrotesk-Bold", size: size) {
            return font
        }
        print("Track this font is wrong")
        return nil
    }
}
