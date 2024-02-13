//
//  ViewController.swift
//  ScanneriOS
//
//  Created by JaeHyeok Sim on 1/31/24.
//

import AVFoundation
import CoreImage
import UIKit

class CameraViewController: UIViewController {
    
    private let cameraView = CameraView()
    
//    private var captureSession: AVCaptureSession!
//    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
//    private var photoOutput: AVCapturePhotoOutput!
//    private var videoDataOutput: AVCaptureVideoDataOutput!
    private var cameraManager: Capturable!
    
    static var croppedImageList: [UIImage] = []
    static var originalImageList: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AVCaptureDevice.requestAccess(for: .video) { (result) in
            if result {
                print("권한 허용 카메라 실행")
            } else {
                print("권한이 없습니다. 카메라 접근 권한을 허용해주세요")
            }
        }
        view.backgroundColor = .gray
        cameraManager = CameraManager(delegate: self)
        setConstraints()
        setupToolBarButton()
        configurationNavigationBar()
        cameraManager.setCamera(cameraView: cameraView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = false
    }
    
    @objc private func cameraButtonDidTap() {
        cameraManager.startCapture()
    }
    
    @objc private func captureViewDidTap() {
        let captureViewController = CaptureViewController()
        self.navigationController?.pushViewController(captureViewController, animated: true)
    }
    
    private func configurationNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "자동/수동", style: .done, target: nil, action: nil)
        self.navigationController?.navigationBar.backgroundColor = .gray
        self.navigationController?.navigationBar.tintColor = .white
    }

    func setupToolBarButton() {
        navigationController?.isToolbarHidden = false
        
        let previewButton = UIButton(type: .custom)
        if let lastImage = CameraViewController.croppedImageList.last {
            let resizedImage = lastImage.resizeImage(targetSize: CGSize(width: 50, height: 50))
            previewButton.setImage(resizedImage, for: .normal)
        } else {
            let originalImage = UIImage(named: "1.jpg")
            let resizedImage = originalImage?.resizeImage(targetSize: CGSize(width: 50, height: 50))
            previewButton.setImage(resizedImage, for: .normal)
        }
        previewButton.addTarget(self, action: #selector(captureViewDidTap), for: .touchUpInside)
        
        let previewBarButtonItem = UIBarButtonItem(customView: previewButton)
        
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: nil)
        deleteButton.tintColor = .white
        let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
        let cameraButton = UIBarButtonItem(image: UIImage(systemName: "camera.viewfinder", withConfiguration: symbolConfiguration), style: .done, target: self, action: #selector(cameraButtonDidTap))
        cameraButton.tintColor = .white

        let saveButton = UIBarButtonItem(title: "저장", style: .done, target: self, action: nil)
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barItems = [previewBarButtonItem, flexibleSpace, cameraButton, flexibleSpace, saveButton]
        
        self.toolbarItems = barItems
        
    }
    
    private func setConstraints() {
        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func detectRectangle(in image: CIImage) -> CIRectangleFeature?  {
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: image) as? [CIRectangleFeature]
        guard let features = features, let feature = features.first  else {
            return nil
        }
        return feature
    }
    

    
    private func getPrepectiveImage(ciImage: CIImage, feature: CIRectangleFeature) -> CIImage? {
        guard let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection") else { return ciImage }
        perspectiveCorrection.setValue(CIVector(cgPoint: feature.topLeft), forKey: "inputTopLeft")
        perspectiveCorrection.setValue(CIVector(cgPoint: feature.topRight), forKey: "inputTopRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: feature.bottomRight), forKey: "inputBottomRight")
        perspectiveCorrection.setValue(CIVector(cgPoint: feature.bottomLeft), forKey: "inputBottomLeft")
        perspectiveCorrection.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = perspectiveCorrection.outputImage else { return nil }
        
        return outputImage
        
    }
}

extension CameraViewController: CameraManagerDelegate {
    
    func recieveImage(capturedImage: CIImage) {
        guard let feature = detectRectangle(in: capturedImage) else { return }
        
        let croppedImage = getPrepectiveImage(ciImage: capturedImage, feature: feature)
        let rotatedImage = UIImage(ciImage: croppedImage!).rotate(degrees: 90)
        let previewImageThumbnailImage = UIImage(ciImage: croppedImage!).rotate(degrees: 90).resizeImage(targetSize: CGSize(width: 50, height: 50))
        
        CameraViewController.croppedImageList.append(rotatedImage)
        DispatchQueue.main.async {
            if let button = self.toolbarItems?.first?.customView as? UIButton {
                button.setImage(previewImageThumbnailImage, for: .normal)
            }
        }
    }
    func displayRectangle(in image: CIImage) {
        guard let feature = detectRectangle(in: image) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.cameraView.layer.sublayers?.removeSubrange(1...)
            self.cameraView.drawRectangle(feature: feature, imageSize: image.extent.size, viewSize: self.cameraView.bounds.size)
        }
    }
    
    
}
