//
//  ViewController.swift
//  PlateReader
//
//  Created by Igor Kovryzhkin on 6/16/17.
//  Copyright © 2017 Igor Kovryzhkin. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController {
    @IBOutlet weak var playbackView: UIView!
    @IBOutlet weak var videoOverlayView: VideoOverlayView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareCaptureSession()
    }
    
    fileprivate func setLayerAsBackground(layer: CALayer) {
        playbackView.layer.addSublayer(layer)
        layer.frame = view.bounds
    }
    
    fileprivate func detectRectangles(image: CIImage) {
        let requestHanlder = VNImageRequestHandler(ciImage: image)
        let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: { (request, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            self.videoOverlayView.drawingRects = request.results as! [VNRectangleObservation]
                DispatchQueue.main.sync {
                    self.videoOverlayView.setNeedsDisplay()
                }
        })
        
        do {
            try requestHanlder.perform([rectDetectRequest])
        } catch {
            
        }
    }
    
    fileprivate func prepareCaptureSession() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
        let input = try! AVCaptureDeviceInput(device: backCamera)
        
        captureSession.addInput(input)
        
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        setLayerAsBackground(layer: cameraPreviewLayer)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer delegate"))
        videoOutput.recommendedVideoSettings(forVideoCodecType: .jpeg, assetWriterOutputFileType: .mp4)
        
        captureSession.addOutput(videoOutput)
        captureSession.sessionPreset = .high
        captureSession.startRunning()
    }
    
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { fatalError("pixel buffer is nil") }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        detectRectangles(image: ciImage)
    }
}

