//
//  OTPScannerViewController.swift
//  Guru
//
//  Created by 堅書真太郎 on 2021/07/01.
//

import AVFoundation
import UIKit

class OTPScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var cameraPreview: UIImageView!
    @IBOutlet weak var explainerLabel: UILabel!
    @IBOutlet weak var manualTypeButton: StylizedButton!
    
    weak var qrCodeResultReceiver: ReceivesQRCodeResult? = nil
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = cameraPreview.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraPreview.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
        
        // Localization
        navigationItem.title = NSLocalizedString("ScanQRCode", comment: "Views")
        explainerLabel.text = NSLocalizedString("OTPExplainer", comment: "OTP")
        manualTypeButton.setTitle(NSLocalizedString("EnterOTPCodeManually", comment: "OTP"), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: Interface Builder
    
    @IBAction func enterCodeManually(_ sender: Any) {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
        showInputAlert(title: "Enter Code Manually",
                       message: "Enter the code displayed on the 2FA setup page of the website/app.",
                       textType: .unspecified,
                       keyboardType: .asciiCapable,
                       capitalizationType: .none,
                       placeholder: "Code",
                       defaultText: "", self) { result in
            if let result = result, result != "" {
                self.found(code: result)
            } else {
                if (self.captureSession?.isRunning == false) {
                    self.captureSession.startRunning()
                }
            }
        }
    }
    
    // MARK: QR Code Functions
    
    func failed() {
        let notSupportedAlert = UIAlertController(title: NSLocalizedString("NoCameraTitle", comment: "OTP"), message: NSLocalizedString("NoCameraText", comment: "OTP"), preferredStyle: .alert)
        notSupportedAlert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "General"), style: .default))
        present(notSupportedAlert, animated: true)
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            found(code: stringValue)
        }
    }
    
    func found(code: String) {
        if qrCodeResultReceiver != nil {
            navigationController?.popViewController(animated: true)
            qrCodeResultReceiver?.receiveQRCode(result: parseOTP(code: code))
        }
    }
    
}
