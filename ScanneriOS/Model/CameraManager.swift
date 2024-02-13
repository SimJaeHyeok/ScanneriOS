//
//  CameraManager.swift
//  ScanneriOS
//
//  Created by JaeHyeok Sim on 2/12/24.
//

import UIKit

import AVFoundation
import CoreImage

class CameraManager: NSObject, Capturable {
    
    private var captureSession: AVCaptureSession!
    private var photoOutput: AVCapturePhotoOutput!
    private var videoDataOutput: AVCaptureVideoDataOutput!
    weak var delegate: CameraManagerDelegate?
    
    init(delegate: CameraManagerDelegate) {
        self.delegate = delegate
    }
    
    func setCamera(cameraView: CameraView) {
        captureSession = AVCaptureSession()
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("카메라 기기 없음")
            return
        }
        guard let deviceInput = try? AVCaptureDeviceInput(device: camera), captureSession.canAddInput(deviceInput) else { return }
        captureSession.addInput(deviceInput)
        
        photoOutput = AVCapturePhotoOutput()
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        captureSession.commitConfiguration()
        
        cameraView.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        DispatchQueue.main.async {
            cameraView.videoPreviewLayer.frame = cameraView.bounds
        }
        cameraView.videoPreviewLayer?.videoGravity = .resize
        cameraView.layer.addSublayer(cameraView.videoPreviewLayer)
        
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
    
    func startCapture() {
        guard let videoConnection = photoOutput.connection(with: .video) else { return }
        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
    
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(), let capturedImage = CIImage(data: data) else {
            print("Failed to convert AVCapturePhoto to UIImage")
            return
        }
        CameraViewController.originalImageList.append(UIImage(ciImage: capturedImage).rotate(degrees: 90))
        delegate?.recieveImage(capturedImage: capturedImage)
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let orientation = windowScene.interfaceOrientation
                output.connection(with: .video)?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
            }
        }
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        
        delegate?.displayRectangle(in: ciImage)
    }
}
