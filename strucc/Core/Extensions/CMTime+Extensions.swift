//
//  CMTime+Extensions.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 29/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import AVFoundation

extension CMTime {
    static func + (lhs: CMTime, rhs: Double) -> CMTime {
        return CMTimeAdd(lhs, CMTime(seconds: rhs, preferredTimescale: 600))
    }

    static func - (lhs: CMTime, rhs: Double) -> CMTime {
        return CMTimeSubtract(lhs, CMTime(seconds: rhs, preferredTimescale: 600))
    }
}
