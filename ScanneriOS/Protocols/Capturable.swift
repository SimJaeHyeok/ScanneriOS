//
//  Capturable.swift
//  ScanneriOS
//
//  Created by JaeHyeok Sim on 2/12/24.
//

import CoreImage
import Foundation

protocol Capturable {
    func startCapture() -> ()
    func setCamera(cameraView: CameraView) -> ()
}


