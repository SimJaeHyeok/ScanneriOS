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
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.backgroundColor = .black
        return cameraView
    }()
    
    
    private let bottomStackView: BottomStackView = {
        let bottomStackView = BottomStackView(frame: .zero)
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.distribution = .equalSpacing
        return bottomStackView
    }()
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var videoDataOutput: AVCaptureVideoDataOutput!
    static var photoList: [UIImage] = []
    
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
        setConstraints()
        configurationNavigationBar()
        configurationCaptureViewTapGesture()
        setCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
    }
    
    @objc private func didTappedCameraButton() {
        guard let videoConnection = photoOutput.connection(with: .video) else { return }
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
    @objc private func didTappedCaptureView() {
        let captureViewController = CaptureViewController()
        self.navigationController?.pushViewController(captureViewController, animated: true)
    }
    
    private func setConstraints() {
        view.addSubview(bottomStackView)
        view.addSubview(cameraView)
        
        NSLayoutConstraint.activate([
            bottomStackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            bottomStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor),
        ])
    }
    
    private func configurationNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "취소", style: .done, target: nil, action: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "자동/수동", style: .done, target: nil, action: nil)
        self.navigationController?.navigationBar.backgroundColor = .gray
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    private func configurationCaptureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedCaptureView))
        bottomStackView.capturePreview.addGestureRecognizer(tapGesture)
        bottomStackView.capturePreview.isUserInteractionEnabled = true
    }
    
    
    private func setCamera() {
        captureSession = AVCaptureSession()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("카메라 기기 없음")
            return
        }
        
        bottomStackView.cameraButton.addTarget(self, action: #selector(didTappedCameraButton), for: .touchUpInside)
        guard let deviceInput = try? AVCaptureDeviceInput(device: camera), captureSession.canAddInput(deviceInput) else { return }
        captureSession.addInput(deviceInput)
        
        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        DispatchQueue.main.async {
            self.videoPreviewLayer.frame = self.cameraView.bounds
        }
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        self.cameraView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
        
        videoDataOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoDataOutput) {
            captureSession.addOutput(videoDataOutput)
            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
        }
    }
    
    private func displayRectangle(in image: CIImage) {
        guard let feature = detectRectangle(in: image) else { return }
        // 피쳐 == 디텍터 다시 그리지 않게..
        DispatchQueue.main.async {
            self.cameraView.layer.sublayers?.removeSubrange(1...)
            self.drawRectangle(feature: feature, imageSize: image.extent.size, viewSize: self.cameraView.bounds.size)
            
        }
    }
    
    private func detectRectangle(in image: CIImage) -> CIRectangleFeature?  {
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: image) as? [CIRectangleFeature]
        guard let features = features, let feature = features.first  else {
            return nil
        }
        return feature
    }
    
    private func drawRectangle(feature: CIRectangleFeature, imageSize: CGSize, viewSize: CGSize) {
        let transformedFeature = translateFeatureCoordinate(feature: feature, imageSize: imageSize, viewSize: viewSize)
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = cameraView.bounds
        shapeLayer.strokeColor = UIColor(named: "SubColor")?.cgColor
        shapeLayer.lineWidth = 2.0
        shapeLayer.opacity = 0.4
        shapeLayer.fillColor = UIColor(named: "MainColor")?.cgColor
        
        
        
        
        let path = UIBezierPath()
        path.move(to: transformedFeature[0])
        path.addLine(to: transformedFeature[1])
        path.addLine(to: transformedFeature[2])
        path.addLine(to: transformedFeature[3])
        path.close()
        
        shapeLayer.path = path.cgPath
        cameraView.layer.addSublayer(shapeLayer)
    }
    
    private func translateFeatureCoordinate(feature: CIRectangleFeature, imageSize: CGSize, viewSize: CGSize) -> [CGPoint] {
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        
        let featurePoint = [feature.topLeft, feature.topRight, feature.bottomRight, feature.bottomLeft] .map {
            var x = $0.x * scaleX
            let y = viewSize.height - ($0.y * scaleY)
            
            if $0 == feature.topLeft || $0 == feature.bottomLeft {
                x -= 20
            } else {
                x += 20
            }
            return CGPoint(x: x, y: y)
        }
        
        return featurePoint
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


extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let capturedImage = CIImage(data: data) else {
            print("Failed to convert AVCapturePhoto to UIImage")
            return
        }
        guard let feature = detectRectangle(in: capturedImage) else { return }
        
        let croppedImage = getPrepectiveImage(ciImage: capturedImage, feature: feature)
        let dqsd = UIImage(ciImage: croppedImage!).rotate(degrees: 90)
        CameraViewController.photoList.append(dqsd)
        DispatchQueue.main.async {
            self.bottomStackView.capturePreview.image = CameraViewController.photoList.last
        }
        
        
        // Enable video output after capturing
        if let videoConnection = output.connection(with: .video) {
            videoConnection.isEnabled = true
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let orientation = windowScene.interfaceOrientation
                output.connection(with: .video)?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
            }
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        displayRectangle(in: ciImage)
    }
}
