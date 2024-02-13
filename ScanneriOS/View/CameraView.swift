//
//  CameraView.swift
//  ScanneriOS
//
//  Created by JaeHyeok Sim on 2/13/24.
//

import AVFoundation
import UIKit

class CameraView: UIView {
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    func drawRectangle(feature: CIRectangleFeature, imageSize: CGSize, viewSize: CGSize) {
        let transformedFeature = translateFeatureCoordinate(feature: feature, imageSize: imageSize, viewSize: viewSize)
        let shapeLayer = CAShapeLayer()
        let path = UIBezierPath()
        
        shapeLayer.frame = self.bounds
        shapeLayer.strokeColor = UIColor(named: "SubColor")?.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.opacity = 0.4
        shapeLayer.fillColor = UIColor(named: "MainColor")?.cgColor
        
        path.move(to: transformedFeature[0])
        path.addLine(to: transformedFeature[1])
        path.addLine(to: transformedFeature[2])
        path.addLine(to: transformedFeature[3])
        path.close()
        
        shapeLayer.path = path.cgPath
        self.layer.addSublayer(shapeLayer)
    }
    
    private func translateFeatureCoordinate(feature: CIRectangleFeature, imageSize: CGSize, viewSize: CGSize) -> [CGPoint] {
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        
        let featurePoint = [feature.topLeft, feature.topRight, feature.bottomRight, feature.bottomLeft] .map {
            let x = $0.x * scaleX
            let y = viewSize.height - ($0.y * scaleY)
            
            return CGPoint(x: x, y: y)
        }
        
        return featurePoint
    }
    
}

