//
//  CameraManagerDelegate.swift
//  ScanneriOS
//
//  Created by JaeHyeok Sim on 2/13/24.
//

import CoreImage

protocol CameraManagerDelegate: AnyObject {
    func recieveImage(capturedImage: CIImage)
    func displayRectangle(in: CIImage)
}
