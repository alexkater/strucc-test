//
//  CIImage+Extension.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 29/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import CoreImage

extension CIImage {
    func applying(orientationTransform: CGAffineTransform?, mirrored: Bool) -> CIImage {
        var result = self

        if let transform = orientationTransform {
            result = result.transformed(by: transform)
        }

        if mirrored {
            let transform = CGAffineTransform(scaleX: -1, y: 1)
            result = result.transformed(by: transform)
        }

        let originTransform = CGAffineTransform(translationX: -result.extent.origin.x, y: -result.extent.origin.y)
        result = result.transformed(by: originTransform)

        return result
    }
}
