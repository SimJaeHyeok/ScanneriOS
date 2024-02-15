//
//  RepointView.swift
//  ScanneriOS
//
//  Created by JaeHyeok Sim on 2/14/24.
//

import UIKit

final class RepointView: UIImageView {
    
    private var circleViews = [CircleView]()
    private let shapeLayer = CAShapeLayer()
    
    func addCircleView(wantCircleNumbers: Int) {
        self.isUserInteractionEnabled = true
        
        for number in 0 ..< wantCircleNumbers {
            let circleView = CircleView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
            circleView.delegate = self
            circleViews.append(circleView)
            self.addSubview(circleViews[number])
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.addSublayer(shapeLayer)
        shapeLayer.lineWidth = 3
        shapeLayer.strokeColor = UIColor(named: "SubColor")?.cgColor
        shapeLayer.fillColor = UIColor(named: "MainColor")?.cgColor
        shapeLayer.opacity = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 베지어 패스가 안그려짐
    
    func drawBezierPath() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: circleViews[0].center.x, y: circleViews[0].center.y))
        path.addLine(to: CGPoint(x: circleViews[1].center.x, y: circleViews[1].center.y))
        path.addLine(to: CGPoint(x: circleViews[2].center.x, y: circleViews[2].center.y))
        path.addLine(to: CGPoint(x: circleViews[3].center.x, y: circleViews[3].center.y))
        path.close()
        
        shapeLayer.path = path.cgPath
    }
}

extension RepointView: CircleViewDelegate {
    func drawArea() {
        drawBezierPath()
    }
}
