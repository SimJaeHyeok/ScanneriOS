//
//  bottomStackView.swift
//  MagicIIDR
//
//  Created by JaeHyeok Sim on 2/1/24.
//

import UIKit

class BottomStackView: UIStackView {
    
    private let cameraButton: UIButton  = {
        let cameraButton = UIButton()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 60)
        let image = UIImage(systemName: "camera.circle.fill", withConfiguration: symbolConfig)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        cameraButton.setImage(image, for: .normal)
        return cameraButton
    }()
    
    private let saveButton: UIButton = {
        let saveButton = UIButton()
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)

        return saveButton
    }()

    let captureView: UIImageView = {
        let captureView = UIImageView()
        captureView.contentMode = .scaleToFill
        captureView.image = UIImage(named: "1.jpeg")
        return captureView
    }()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setConstrains()
        }

        required init(coder: NSCoder) {
            super.init(coder: coder)
        }

    func setConstrains() {
        self.addArrangedSubview(captureView)
        self.addArrangedSubview(cameraButton)
        self.addArrangedSubview(saveButton)

        NSLayoutConstraint.activate([
            captureView.heightAnchor.constraint(equalTo: cameraButton.heightAnchor),
            captureView.widthAnchor.constraint(equalTo: cameraButton.widthAnchor),
            saveButton.heightAnchor.constraint(equalTo: cameraButton.heightAnchor),
            saveButton.widthAnchor.constraint(equalTo: cameraButton.widthAnchor),
//            cameraButton.heightAnchor.constraint(equalTo: .heightAnchor)
            ])
    }
    
}
