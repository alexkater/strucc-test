//
//  Routes.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

enum Routes: Equatable {
    case camera
    case preview(urls: [URL])

    var controller: UIViewController {
        switch self {
        case .camera: return CameraViewController()
        case .preview(let urls):
            let viewModel = PreviewViewModel(urls: urls)
            return PreviewViewController(viewModel: viewModel)
        }
    }
}
