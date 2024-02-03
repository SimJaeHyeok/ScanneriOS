//
//  ViewController.swift
//  MagicIIDR
//
//  Created by JaeHyeok Sim on 1/31/24.
//

import UIKit
import CoreImage
import AVFoundation

class CameraViewController: UIViewController {
    
    private let cameraView: UIView = {
        let cameraView = UIView()
        return cameraView
    }()
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    
    private let bottomStackView: BottomStackView = {
        let bottomStackView = BottomStackView(frame: .zero)
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.distribution = .equalSpacing
        return bottomStackView
    }()
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .gray
        setConstraints()
        configurationNavigationBar()
        tapCaptureView()
    }
    
    func detectRectangleAndCorrectPerspective(image: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }
        
        // Create a rectangle detector
        let options: [String: Any] = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        guard let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options) else { return nil }
        
        // Detect rectangles
        let features = detector.features(in: ciImage)
        guard let rectangleFeature = features.first as? CIRectangleFeature else { return nil }
        
        // Correct perspective
        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.topLeft), forKey: "inputTopLeft")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.topRight), forKey: "inputTopRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrection?.setValue(CIVector(cgPoint: rectangleFeature.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrection?.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = perspectiveCorrection?.outputImage else { return nil }
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        // Return the corrected image
        return UIImage(cgImage: cgImage)
    }
    
    @objc func didTakePhoto() {
        
    }
    
    private func setConstraints() {
        view.addSubview(bottomStackView)
        
        NSLayoutConstraint.activate([
            bottomStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            bottomStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func configurationNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "자동/수동", style: .done, target: nil, action: nil)
        self.navigationController?.navigationBar.backgroundColor = .gray
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    private func tapCaptureView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView))
        bottomStackView.captureView.addGestureRecognizer(tapGesture)
        bottomStackView.captureView.isUserInteractionEnabled = true
        
        
    }
    @objc func tapView() {
        let captureViewController = CaptureViewController()
        self.navigationController?.pushViewController(captureViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
    }

}
