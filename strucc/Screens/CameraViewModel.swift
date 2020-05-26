//
//  CameraViewModel.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 26/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation

protocol CameraViewModelProtocol {
    var isButtonSelected: Bool { get }
    var navigate: Any
    
    func record()
}

final class CameraViewModel: CameraViewModelProtocol {

}
