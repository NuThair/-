//
//  DetailAssVideoRec.swift
//  OBQI
//
//  Created by t.o on 2017/06/07.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import AudioToolbox

class DetailAssVideoRec: UIViewController, AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        // ライブラリへ保存
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
        }) { completed, error in
            if completed {
                print("Video is saved!")
            }
        }
    }
    
    
    
    // セッション
    var mySession : AVCaptureSession!
    // デバイス
    var videoDevice : AVCaptureDevice!
    var audioDevice : AVCaptureDevice!
    // 画像のインプット
    var videoInput : AVCaptureDeviceInput!
    var audioInput : AVCaptureInput!
    // 画像のアウトプット
    var videoOutput : AVCaptureMovieFileOutput!
    // 画像表示のレイヤー
    var myVideoLayer : AVCaptureVideoPreviewLayer!
    // 撮影ボタン
    var captureButton: UIButton!


    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let block = Block()

    var isRecording = false
    var oldZoomScale: CGFloat = 1.0

    override var prefersStatusBarHidden : Bool {
        return true
    }
    override var shouldAutorotate : Bool{
        return true
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscape
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // AVCaptureSession: キャプチャに関する入力と出力の管理
        self.mySession = AVCaptureSession()

        // sessionPreset: キャプチャ・クオリティの設定
        self.mySession.sessionPreset = AVCaptureSession.Preset.medium

        // 背面カsメラの選択
        //self.videoDevice = AVCaptureDevice.defaultDevice(withDeviceType: .builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .back)
        self.videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)

        // 動画入力をセッションに追加
        do {
            self.videoInput = try AVCaptureDeviceInput(device: self.videoDevice) as AVCaptureDeviceInput

            if !self.mySession.canAddInput(self.videoInput) {
                // 閉じる
                self.dismiss(animated: true, completion: nil)
            }
            self.mySession.addInput(self.videoInput)

        } catch let error as NSError {
            print(error)
            // 閉じる
            self.dismiss(animated: true, completion: nil)
        }

        // 音声入力をセッションに追加
        self.audioDevice = AVCaptureDevice.default(for: .audio)
        do {
            self.audioInput = try AVCaptureDeviceInput(device: self.audioDevice) as AVCaptureDeviceInput

            if !self.mySession.canAddInput(self.audioInput) {
                // 閉じる
                self.dismiss(animated: true, completion: nil)
            }
            self.mySession.addInput(self.audioInput)

        } catch let error as NSError {
            print(error)
            // 閉じる
            self.dismiss(animated: true, completion: nil)
        }

        // レイヤー追加
        self.myVideoLayer = AVCaptureVideoPreviewLayer(session: self.mySession)
        self.myVideoLayer.frame = self.view.bounds
        self.myVideoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(self.myVideoLayer)

        // AVCaptureMovieFileOutput:動画ファイルを出力に設定
        self.videoOutput = AVCaptureMovieFileOutput()

        // 出力をセッションに追加
        if !self.mySession.canAddOutput(self.videoOutput) {
            // 閉じる
            self.dismiss(animated: true, completion: nil)
        }
        self.mySession.addOutput(self.videoOutput)


        // 回転させる
        setOrientation()

        // UIボタンを作成.
        captureButton = UIButton(frame: CGRect(x: 0,y: 0,width: 120,height: 50))
        captureButton.backgroundColor = UIColor.photoViewButton().withAlphaComponent(0.7)
        captureButton.layer.masksToBounds = true
        captureButton.setTitle("撮影", for: UIControl.State())
        captureButton.layer.cornerRadius = 10.0
        captureButton.layer.position = CGPoint(x: (self.view.bounds.width/3)*2, y:self.view.bounds.height-50)
        captureButton.addTarget(self, action: #selector(self.onClickCaptureButton(sender:)), for: .touchUpInside)
        captureButton.setTitleColor(UIColor.gray, for: .highlighted)

        // UIボタンを作成.
        let closeButton = UIButton(frame: CGRect(x: 0,y: 0,width: 120,height: 50))
        closeButton.backgroundColor = UIColor.photoViewButton().withAlphaComponent(0.7)
        closeButton.layer.masksToBounds = true
        closeButton.setTitle("閉じる", for: UIControl.State())
        closeButton.layer.cornerRadius = 10.0
        closeButton.layer.position = CGPoint(x: self.view.bounds.width/3, y:self.view.bounds.height-50)
        closeButton.addTarget(self, action: #selector(self.onClickCloseButton(sender:)), for: .touchUpInside)
        closeButton.setTitleColor(UIColor.gray, for: .highlighted)


        // UIボタンをViewに追加.
        self.view.addSubview(captureButton);
        self.view.addSubview(closeButton);

        self.mySession.startRunning()
    }

    // 画面回転時に呼び出される
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        setOrientation()
    }

    // 画面回転
    func setOrientation() {
        myVideoLayer.frame = self.view.bounds

        // 方向の特定
        var ori : AVCaptureVideoOrientation!
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft:
            ori = AVCaptureVideoOrientation.landscapeLeft
        case .landscapeRight:
            ori = AVCaptureVideoOrientation.landscapeRight
        case .portrait:
            ori = AVCaptureVideoOrientation.portrait
        case .portraitUpsideDown:
            ori = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            break
        }

        self.myVideoLayer.connection?.videoOrientation = ori

        // 出力も同じように回転させる
        let captureConnection = self.videoOutput.connection(with: AVMediaType.video)
        captureConnection?.videoOrientation = ori
    }

    // 撮影開始・終了
    @objc func onClickCaptureButton(sender: UIButton){
        if self.isRecording { // 録画終了
            // 録画終了
            self.videoOutput.stopRecording()

            // 録画ボタン色変更
            captureButton.backgroundColor = UIColor.photoViewButton().withAlphaComponent(0.7)

            // sound
            let soundIdRing:SystemSoundID = 1118  // end_video_record.caf
            AudioServicesPlaySystemSound(soundIdRing)

        } else { // 録画開始
            // 録画ボタン色変更
            captureButton.backgroundColor = UIColor.recordingButton().withAlphaComponent(0.7)

            // NOTE 動画撮影開始時の暗転が気になる場合はremoveInput、addInput部を削除する
            // 録画開始音が動画に入らないように一旦音声インプットを削除
            self.mySession.removeInput(self.audioInput)

            // sound
            let soundIdRing:SystemSoundID = 1117  // begin_video_record.caf
            AudioServicesPlaySystemSound(soundIdRing)

            // 音声インプット追加
            self.mySession.addInput(self.audioInput)

            // start recording
            let tmpPath = NSTemporaryDirectory()
            // ファイル名.
            let filePath = "\(tmpPath)tmp.mp4"
            // URL.
            let fileURL = URL(fileURLWithPath: filePath)
            // 録画開始.
            self.videoOutput.startRecording(to: fileURL, recordingDelegate: self as
                                                AVCaptureFileOutputRecordingDelegate)
        }

        self.isRecording = !self.isRecording
    }

    // 閉じる
    @objc func onClickCloseButton(sender: UIButton) {
        // 撮影中の場合は破棄するか確認
        if self.isRecording {
            // アラートアクションの設定
            var actionList = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()

            // キャンセルアクション
            actionList.append(
                (
                    title: "破棄しない",
                    style: UIAlertAction.Style.cancel,
                    action: {
                        (action: UIAlertAction!) -> Void in
                        print("UnRevocation")                })
            )

            // OKアクション
            actionList.append(
                (
                    title: "破棄する   ",
                    style: UIAlertAction.Style.default,
                    action: {
                        (action: UIAlertAction!) -> Void in
                        print("Revocation")

                        // 閉じる
                        self.dismiss(animated: true, completion: nil)
                })
            )
            
            AppCommon.alertAnyAction(controller: self, title: "確認", message: "撮影中の動画を破棄しますか？", actionList: actionList)

        } else {
            // 閉じる
            self.dismiss(animated: true, completion: nil)
        }
    }

    // 撮影終了時にコールされる
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        // ブロックUI表示
        block.showBlockUI(view)

        let myMovideData = try? Data(contentsOf: outputFileURL)
        let fileStringString = myMovideData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        let fileString = fileStringString! as NSString
        let length = fileString.length

        let customerID = self.appDelegate.SelectedCustomer!["CustomerID"].asString!
        let assID = String(self.appDelegate.SelectedAssAssID!)
        let itemID = appDelegate.SelectedMstAssessmentItem!["AssItemID"].asInt!
        let assMenuGroupID = self.appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = self.appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!

        let now = NSDate() // 現在日時の取得
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMddHHmmssSSS" // 日付フォーマットの設定
        let createDate = dateFormatter.string(from: now as Date)
        var subStrLocation = 0
        var subStrLength = 0
        var count = 0
        var cutString = ""
        let sendLength = 1000000
        var array : [NSString] = []
        while (length > subStrLocation + subStrLength) {
            subStrLocation = sendLength * count
            subStrLength = sendLength
            if (subStrLocation + subStrLength > length)
            {
                subStrLength = length - subStrLocation
            }

            cutString = fileString.substring(with: NSRange(location: subStrLocation, length: subStrLength))
            array.append(cutString as NSString)
            count += 1
        }


        let url = "\(AppConst.URLPrefix)assessment/PostAssMovieFile"
        let endIndex = array.count - 1
        for i in (0 ..< array.count) {
            let params: [String: AnyObject] = [
                "CustomerID": customerID as AnyObject,
                "AssID": assID as AnyObject,
                "AssMenuGroupID": String(assMenuGroupID) as AnyObject,
                "AssMenuSubGroupID": String(assMenuSubGroupID) as AnyObject,
                "ItemID": String(itemID) as AnyObject,
                "Extention": "mp4" as AnyObject,
                "FileData": array[i],
                "Index": i as AnyObject,
                "StartIndex": "0" as AnyObject,
                "EndIndex": endIndex as AnyObject,
                "Createdatetime": createDate as AnyObject,
                ]
            _ = self.appCommon.postSynchronous(url, params: params)
        }

        // フラグを変更する
        self.appDelegate.ChangeInputAssFlagForList = true
        self.appDelegate.ChangeInputAssFlagForShcema = true

        // 閉じる
        self.dismiss(animated: true, completion: nil)
    }

    // カメラズーム
    @IBAction func pinchToZoom(_ sender: UIPinchGestureRecognizer) {
        guard let device = videoDevice else { return }

        do {
            try device.lockForConfiguration()
            // ズームの最大値
            let maxZoomScale: CGFloat = 6.0
            // ズームの最小値
            let minZoomScale: CGFloat = 1.0
            // 現在のカメラのズーム度
            var currentZoomScale: CGFloat = device.videoZoomFactor
            // ピンチの度合い
            let pinchZoomScale: CGFloat = sender.scale

            // ピンチアウトの時、前回のズームに今回のズーム-1を指定
            // 例: 前回3.0, 今回1.2のとき、currentZoomScale=3.2
            if pinchZoomScale > 1.0 {
                currentZoomScale = oldZoomScale+pinchZoomScale-1
            } else {
                currentZoomScale = oldZoomScale-(1-pinchZoomScale)*oldZoomScale
            }

            // 最小値より小さく、最大値より大きくならないようにする
            if currentZoomScale < minZoomScale {
                currentZoomScale = minZoomScale
            }
            else if currentZoomScale > maxZoomScale {
                currentZoomScale = maxZoomScale
            }

            // 画面から指が離れたとき、stateがEndedになる。
            if sender.state == .ended {
                oldZoomScale = currentZoomScale
            }

            device.videoZoomFactor = currentZoomScale
            device.unlockForConfiguration()

        } catch {
            // handle error
            return
        }
    }
}
