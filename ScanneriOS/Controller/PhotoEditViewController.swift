//
//  PhotoEditViewController.swift
//  MagicIIDR
//
//  Created by JaeHyeok Sim on 2/2/24.
//

import UIKit

class PhotoEditViewController: UIViewController {
    
    private let backButton: UIButton = {
        let backButton = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        let iconImage = UIImage(systemName: "chevron.backward", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        backButton.setImage(iconImage, for: .normal)
        backButton.addTarget(nil, action: #selector(tapBackButton), for: .touchUpInside)
        return backButton
    }()
    
    private let checkButton: UIButton = {
        let checkButton = UIButton()
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        let iconImage = UIImage(systemName: "checkmark", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        checkButton.setImage(iconImage, for: .normal)
//        checkButton.addTarget(nil, action: #selector(tapCutButton), for: .touchUpInside)
        return checkButton
    }()
    
    private let photoEditView: UIImageView = {
        let photoEditView = UIImageView()
        photoEditView.translatesAutoresizingMaskIntoConstraints = false
        return photoEditView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        navigationController?.navigationBar.isHidden = true
        navigationController?.isToolbarHidden = false
        setupToolBarButton()
        setLayout()
        setConstraints()
    }
    
    func setLayout() {
        view.addSubview(photoEditView)
        photoEditView.backgroundColor = .black
    }
    
    func setConstraints() {
        NSLayoutConstraint.activate([
            photoEditView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            photoEditView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            photoEditView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            photoEditView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        guard let photo = CameraViewController.photoList.last else { return }
        photoEditView.image = photo
    }
    
    @objc func tapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func setupToolBarButton() {
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        let backSymbol = UIImage(systemName: "chevron.backward", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let backButton = UIBarButtonItem(image: backSymbol, style: .done, target: self, action: #selector(tapBackButton))
        let checkSymbol = UIImage(systemName: "checkmark", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let checkButton = UIBarButtonItem(image: checkSymbol, style: .done, target: self, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barItems = [backButton, flexibleSpace, checkButton]

        self.toolbarItems = barItems
        
    }
}
