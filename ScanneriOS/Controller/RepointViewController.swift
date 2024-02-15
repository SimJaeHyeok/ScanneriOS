//
//  PhotoEditViewController.swift
//  MagicIIDR
//
//  Created by JaeHyeok Sim on 2/2/24.
//

import UIKit

final class RepointViewController: UIViewController {
    
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
    
    private let repointView: RepointView = {
        let photoEditView = RepointView(frame: CGRect(origin: .zero, size: .zero))
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
        repointView.addCircleView(wantCircleNumbers: 4)
    }
    
    private func setLayout() {
        view.addSubview(repointView)
        repointView.image = CameraViewController.originalImageList.last
    }
    
   private func setConstraints() {
        NSLayoutConstraint.activate([
            repointView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            repointView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            repointView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            repointView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        guard let photo = CameraViewController.originalImageList.last else { return }
        repointView.image = photo
    }
    
    @objc func tapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
   private func setupToolBarButton() {
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
