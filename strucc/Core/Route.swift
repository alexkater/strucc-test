//
//  Routes.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

enum Route: Equatable {
    case camera
    case preview(urls: [URL])

    var controller: UIViewController {
        switch self {
        case .camera:
            let viewModel = CameraViewModel()
            return CameraViewController(viewModel: viewModel)
        case .preview(let urls):
            let viewModel = PreviewViewModel(urls: urls)
            return PreviewViewController(viewModel: viewModel)
        }
    }
}
