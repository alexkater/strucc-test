//
//  Routes.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

enum Routes {
    case camera, preview

    var controller: UIViewController {
        switch self {
        case .camera: return CameraViewController()
        case .preview: return UIViewController()
        }
    }
}
