//
//  UIImage+Extension.swift
//  ScanneriOS
//
//  Created by JaeHyeok Sim on 2/8/24.
//

import UIKit

extension UIImage {

    func rotate(degrees: CGFloat) -> UIImage {
            let radians = degrees * .pi / 180
            let newRect = CGRect(origin: .zero, size: self.size)
                .applying(CGAffineTransform(rotationAngle: radians))
            let renderer = UIGraphicsImageRenderer(size: newRect.size)

            let image = renderer.image { context in
                context.cgContext.translateBy(x: newRect.width / 2, y: newRect.height / 2)
                context.cgContext.rotate(by: radians)
                draw(in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
            }

            return image
        }
}

extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        let newSize = widthRatio > heightRatio ? CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
