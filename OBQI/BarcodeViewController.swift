//
//  BarcodeViewController.swift
//  SkinFloraME
//
//  Created by ToyamaYoshimasa on 2015/04/21.
//  Copyright (c) 2015年 OrangeAct. All rights reserved.
//

import UIKit
import AVFoundation

class BarcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    let session: AVCaptureSession = AVCaptureSession()
    var prevlayer: AVCaptureVideoPreviewLayer!
    var hview: UIView = UIView()
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override var shouldAutorotate : Bool{
        return true
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //準備（サイズ調整、ボーダーカラー、カメラオブジェクト取得、エラー処理）
        self.hview.autoresizingMask =   [UIView.AutoresizingMask.flexibleTopMargin, UIView.AutoresizingMask.flexibleBottomMargin, UIView.AutoresizingMask.flexibleLeftMargin, UIView.AutoresizingMask.flexibleRightMargin]
        self.hview.layer.borderColor = UIColor.green.cgColor
        self.hview.layer.borderWidth = 3
        self.view.addSubview(self.hview)
       // let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let device = AVCaptureDevice.default(for: .video)

        //インプット
        do {
            let input = try AVCaptureDeviceInput(device: device!) as AVCaptureDeviceInput
            session.addInput(input)//カメラインプットセット
        }catch let error as NSError {
            print(error)
        }
        
        //アウトプット
        let output = AVCaptureMetadataOutput()
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)//プレビューアウトプットセット
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        prevlayer = AVCaptureVideoPreviewLayer(session: session)
        
        let rect = CGRect(x: 0,y: 0,width: self.view.bounds.width,height: self.view.bounds.height)
        prevlayer.frame = rect
        // 回転させる
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            prevlayer.connection!.videoOrientation = .landscapeLeft
        case .landscapeRight:
            prevlayer.connection!.videoOrientation = .landscapeRight
        case .portrait:
            prevlayer.connection!.videoOrientation = .portrait
        case .portraitUpsideDown:
            prevlayer.connection!.videoOrientation = .portraitUpsideDown
        default:
            break
        }
        prevlayer.videoGravity = AVLayerVideoGravity.resizeAspect

        self.view.layer.addSublayer(prevlayer)
        session.startRunning()//開始！
        
        
        // UIボタンを作成.
        let closeButton = UIButton(frame: CGRect(x: 0,y: 0,width: 120,height: 50))
        closeButton.backgroundColor = UIColor.photoViewButton().withAlphaComponent(0.7)
        closeButton.layer.masksToBounds = true
        closeButton.setTitle("閉じる", for: UIControl.State())
        closeButton.layer.cornerRadius = 10.0
        closeButton.layer.position = CGPoint(x: self.view.bounds.width/2, y:self.view.bounds.height-50)
        closeButton.addTarget(self, action: #selector(BarcodeViewController.onClickCancelButton(_:)), for: .touchUpInside)
        closeButton.setTitleColor(UIColor.gray, for: .highlighted)
        
        // UIボタンをViewに追加.
        self.view.addSubview(closeButton);

    }
    // 画面回転時に呼び出される
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        let rect = CGRect(x: 0,y: 0,width: self.view.bounds.width,height: self.view.bounds.height)
        prevlayer.frame = rect

        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            prevlayer.connection!.videoOrientation = .landscapeLeft
        case .landscapeRight:
            prevlayer.connection?.videoOrientation = .landscapeRight
        case .portrait:
            prevlayer.connection!.videoOrientation = .portrait
        case .portraitUpsideDown:
            prevlayer.connection!.videoOrientation = .portraitUpsideDown
        default:
            break
        }
    }
    @objc func onClickCancelButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    
    //バーコードが見つかった時に呼ばれる
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        var detectionString : String!
        
        //対応バーコードタイプ
        let barCodeTypes = [AVMetadataObject.ObjectType.upce,
                            AVMetadataObject.ObjectType.code39,
                            AVMetadataObject.ObjectType.code39Mod43,
                            AVMetadataObject.ObjectType.ean13,
                            AVMetadataObject.ObjectType.ean8,
                            AVMetadataObject.ObjectType.code93,
                            AVMetadataObject.ObjectType.code128,
                            AVMetadataObject.ObjectType.pdf417,
                            AVMetadataObject.ObjectType.qr,
                            AVMetadataObject.ObjectType.aztec
        ]
        
        //複数のバーコードの同時取得も可能
        for metadata in metadataObjects {
            for barcodeType in barCodeTypes {
                if (metadata as AnyObject).type == barcodeType {
                    detectionString = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.session.stopRunning()
                    break
                }
            }
        }
        
        appDelegate.CaptureBarcode = detectionString
        dismiss(animated: true, completion: nil)
    }
}
