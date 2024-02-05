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
    
    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var photoSetting: AVCapturePhotoSettings!
    static var photoList: [UIImage] = []
    
    private let bottomStackView: BottomStackView = {
        let bottomStackView = BottomStackView(frame: .zero)
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.distribution = .equalSpacing
        return bottomStackView
    }()
    

    
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
        tapCaptureView()
        settingPhoto()
        setCamera()
    }
    
    @objc func tapCameraButton() {
        photoOutput.capturePhoto(with: photoSetting, delegate: self)
        settingPhoto()
    }
    
    @objc func tapView() {
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
            cameraView.bottomAnchor.constraint(equalTo: bottomStackView.topAnchor)

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
        bottomStackView.capturePreView.addGestureRecognizer(tapGesture)
        bottomStackView.capturePreView.isUserInteractionEnabled = true
    
        
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
        bottomStackView.cameraButton.addTarget(self, action: #selector(tapCameraButton), for: .touchUpInside)
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
    }
    
    private func settingPhoto() {
        photoSetting = AVCapturePhotoSettings()
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation() else { return }
        
        let photoData = UIImage(data: data)
        
        guard let photo = photoData else { return }
        Self.photoList.append(photo)
        DispatchQueue.main.async {
            self.bottomStackView.capturePreView.image = photo
        }
    }
}
