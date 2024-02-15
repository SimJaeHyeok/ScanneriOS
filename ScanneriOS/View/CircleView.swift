//
//  CircleView.swift
//  ScanneriOS
//
//  Created by JaeHyeok Sim on 2/14/24.
//

import UIKit

final class CircleView: UIView {
    
    var delegate: CircleViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .darkGray
        self.layer.cornerRadius = 10
        
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(moveView))
        self.addGestureRecognizer(gesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func moveView(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.superview)
        delegate?.drawArea()
    }
}

