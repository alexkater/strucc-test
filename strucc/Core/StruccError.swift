//
//  StruccError.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation

enum StruccError: Error {
    case undeterminedError, cantTakeTracks, cantTakeAVAssetTracks, selfDeinitialized, cantInsertTimeRange

    var description: String {
        switch self {
        default: return "Oooops! Something has happened"
        }
    }
}
