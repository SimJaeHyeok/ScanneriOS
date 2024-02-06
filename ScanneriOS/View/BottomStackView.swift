//
//  bottomStackView.swift
//  MagicIIDR
//
//  Created by JaeHyeok Sim on 2/1/24.
//

import UIKit

class BottomStackView: UIStackView {
    
    let cameraButton: UIButton  = {
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

    let capturePreview: UIImageView = {
        let capturePreview = UIImageView()
        capturePreview.contentMode = .scaleToFill
        capturePreview.image = UIImage(named: "1.jpeg")
        capturePreview.layer.borderColor = UIColor.black.cgColor
        capturePreview.layer.borderWidth = 1.0
        return capturePreview
    }()
    
    override init(frame: CGRect) {
            super.init(frame: frame)
            setConstrains()
        }

        required init(coder: NSCoder) {
            super.init(coder: coder)
        }

    func setConstrains() {
        self.addArrangedSubview(capturePreview)
        self.addArrangedSubview(cameraButton)
        self.addArrangedSubview(saveButton)

        NSLayoutConstraint.activate([
            capturePreview.heightAnchor.constraint(equalTo: cameraButton.heightAnchor),
            capturePreview.widthAnchor.constraint(equalTo: cameraButton.widthAnchor),
            saveButton.heightAnchor.constraint(equalTo: cameraButton.heightAnchor),
            saveButton.widthAnchor.constraint(equalTo: cameraButton.widthAnchor),
            ])
    }
    
}
