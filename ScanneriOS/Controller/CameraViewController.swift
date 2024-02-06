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
    private var photoSetting: AVCapturePhotoSettings!
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
        configCaptureViewTapGesture()
        setPhotoSetting()
        setCamera()
    }
    
    @objc private func didTappedCameraButton() {
           guard let videoConnection = photoOutput.connection(with: .video) else { return }
           
           // Capture a photo with the current video orientation
           photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
           
           // Disable video output momentarily to prevent further processing while capturing
           videoConnection.isEnabled = false
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
    
    private func configCaptureViewTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedCaptureView))
        bottomStackView.capturePreview.addGestureRecognizer(tapGesture)
        bottomStackView.capturePreview.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isToolbarHidden = true
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
    
    private func setPhotoSetting() {
        photoSetting = AVCapturePhotoSettings()
    }
    
    private func detectRectangle(in image: CIImage) {
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let features = detector?.features(in: image) as? [CIRectangleFeature]
       

        DispatchQueue.main.async {
            self.cameraView.layer.sublayers?.removeSubrange(1...)
            for feature in features ?? [] {
                self.drawRectangle(feature: feature)
            }
        }
    }

    private func drawRectangle(feature: CIRectangleFeature) {
        let shapeLayer = CAShapeLayer()

        let convertedTopLeft = cameraView.layer.convert(feature.topLeft, from: videoPreviewLayer)
        let convertedTopRight = cameraView.layer.convert(feature.topRight, from: videoPreviewLayer)
        let convertedBottomLeft = cameraView.layer.convert(feature.bottomLeft, from: videoPreviewLayer)
        let convertedBottomRight = cameraView.layer.convert(feature.bottomRight, from: videoPreviewLayer)

        let path = UIBezierPath()
        path.move(to: convertedTopLeft)
        path.addLine(to: convertedTopRight)
        path.addLine(to: convertedBottomRight)
        path.addLine(to: convertedBottomLeft)
        path.close()

        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2

        cameraView.layer.addSublayer(shapeLayer)
    }
    
    private func adjustRectForPreview(_ rect: CGRect, in previewRect: CGRect) -> CGRect {
        let scaleX = previewRect.width / videoPreviewLayer.bounds.width
        let scaleY = previewRect.height / videoPreviewLayer.bounds.height

        let transformedRect = rect.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))

        let offsetY = (previewRect.height - videoPreviewLayer.bounds.height * scaleY) / 2.0
        let adjustedRect = transformedRect.offsetBy(dx: 0, dy: offsetY)

        return adjustedRect
    }
    
    private func processCapturedImage(_ image: UIImage) {
           // Add your logic to handle the captured image, for example, displaying or saving it
           print("Captured image processed")
       }
    
    
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let capturedImage = UIImage(data: data) else {
            print("Failed to convert AVCapturePhoto to UIImage")
            return
        }

        // Process the captured image (optional)
        processCapturedImage(capturedImage)
        CameraViewController.photoList.append(capturedImage)
        // Display the captured image in capturePreView
        DispatchQueue.main.async {
            self.bottomStackView.capturePreview.image = capturedImage
        }
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        // Detect and draw rectangles
        detectRectangle(in: ciImage)
    }
}
