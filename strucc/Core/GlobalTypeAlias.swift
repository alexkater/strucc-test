//
//  GlobalTypeAlias.swift
//  strucc
//
//  Created by Alejandro Arjonilla Garcia on 29/05/2020.
//  Copyright © 2020 aarjincc. All rights reserved.
//

import Foundation
import AVFoundation
import CoreImage
import Combine

typealias SelectionCallback = ((Int) -> Void)
typealias FilterFunc = (CIImage) -> CIImage?
typealias Composition = (AVComposition, AVVideoComposition?)
typealias CompositionFuture = Future<Composition, StruccError>
typealias CompositionCompletion = (Composition) -> Void
