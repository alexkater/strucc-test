//
//  UIViewController+Error.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 31/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import UIKit

extension UIViewController {

    func show(error: String?, completionAction: (() -> Void)? = nil) {
        guard let error = error, !error.isEmpty else { return }
        let alert = UIAlertController(title: "Really Sorry",
                                      message: error, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok I understand", style: .default) { [weak self] (_) in
            self?.dismiss(animated: true, completion: completionAction)
        }
        alert.addAction(defaultAction)

        present(alert, animated: true, completion: nil)
    }
}
