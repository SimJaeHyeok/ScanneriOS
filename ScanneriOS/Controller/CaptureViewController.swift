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
        return photoView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        navigationController?.isToolbarHidden = false
        setupToolBarButton()
    }
    
    @objc func tapCutButton() {
        let photoEditViewController = PhotoEditViewController()
        self.navigationController?.pushViewController(photoEditViewController, animated: true)
    }
    
    func setupToolBarButton() {
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
        deleteButton.tintColor = .white
        let completeButton = UIBarButtonItem(title: "완료", style: .plain, target: self, action: nil)
        completeButton.tintColor = .white
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        let cropSymbol = UIImage(systemName: "scissors", withConfiguration: symbolConfiguration)?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let cutButton = UIBarButtonItem(image: cropSymbol, style: .done, target: self, action: #selector(tapCutButton))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barItems = [deleteButton, flexibleSpace, completeButton, flexibleSpace, cutButton]

        self.toolbarItems = barItems

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
}
