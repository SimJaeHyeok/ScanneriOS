//
//  CaptureViewController.swift
//  MagicIIDR
//
//  Created by JaeHyeok Sim on 2/2/24.
//

import UIKit

class CaptureViewController: UIViewController {

    
    private let photoView: UIImageView = {
        let photoView = UIImageView()
        photoView.translatesAutoresizingMaskIntoConstraints = false
        photoView.backgroundColor = .black
        return photoView
    }()
    
    private var rotateCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(photoView)
        view.backgroundColor = .gray
        navigationController?.isToolbarHidden = false
        setupToolBarButton()
        setConstraints()
        displayPhoto()
    }
    
    @objc func cutButtonDidTap() {
        let photoEditViewController = RepointViewController()
        self.navigationController?.pushViewController(photoEditViewController, animated: true)
    }
    
    @objc func rotateButtonDidTap() {
        guard let photo = CameraViewController.croppedImageList.last else { return }
        rotateCount += 1
        
        if rotateCount == 1 {
            photoView.image = photo.rotate(degrees: 90)
        } else if rotateCount == 2 {
            photoView.image = photo.rotate(degrees: 180)
        } else if rotateCount == 3 {
            photoView.image = photo.rotate(degrees: 270)
        } else if rotateCount == 4 {
            photoView.image = photo
            rotateCount = 0
        }
    }
    
    func setupToolBarButton() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
        deleteButton.tintColor = .white
        
        let completeButton = UIBarButtonItem(title: "반시계", style: .plain, target: self, action: #selector(rotateButtonDidTap))
        completeButton.tintColor = .white
        
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        let cropSymbol = UIImage(systemName: "scissors", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let cutButton = UIBarButtonItem(image: cropSymbol, style: .done, target: self, action: #selector(cutButtonDidTap))
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barItems = [deleteButton, flexibleSpace, completeButton, flexibleSpace, cutButton]

        self.toolbarItems = barItems

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    private func setConstraints() {
        NSLayoutConstraint.activate([
            photoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            photoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            photoView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func displayPhoto() {
        guard let photo = CameraViewController.croppedImageList.last else { return }
        photoView.image = photo
    }
}
