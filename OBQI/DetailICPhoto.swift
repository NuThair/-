//
//  DetailAssPhoto.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/11.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit
import AVFoundation

class DetailICPhoto: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 写真のリスト
    var ICPhotoFileList : JSON?

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let icCommon = ICCommon()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonDelete: UIBarButtonItem!
    @IBOutlet weak var buttonAllDelete: UIBarButtonItem!

    // 写真ボタンを入れる
    var subViewButtons : [UIButton] = []
    // 選択されているSEQNO
    var selectedSeqNo : Int?
    let photoButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))

    let appCommon = AppCommon()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Viewの高さと幅を取得する.
        let displayHeight: CGFloat = self.view.frame.height
        // Status Barの高さを取得をする.
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width

        // UIボタンを作成.
        let selectButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
        selectButton.backgroundColor = UIColor.photoViewButton()
        selectButton.layer.masksToBounds = true
        selectButton.setTitle("写真選択", for: UIControl.State())
        selectButton.layer.cornerRadius = 10.0
        selectButton.layer.position = CGPoint(x: (navBarWidth!/2), y:displayHeight-50)
        selectButton.addTarget(self, action: #selector(DetailICPhoto.pickImageFromLibrary(_:)), for: .touchUpInside)
        selectButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(selectButton);
        // UIボタンを作成.
        let closeButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
        closeButton.backgroundColor = UIColor.photoViewButton()
        closeButton.layer.masksToBounds = true
        closeButton.setTitle("撮影", for: UIControl.State())
        closeButton.layer.cornerRadius = 10.0
        closeButton.layer.position = CGPoint(x: (navBarWidth!/2)-200, y:displayHeight-50)
        closeButton.addTarget(self, action: #selector(DetailICPhoto.ClickCamera(_:)), for: .touchUpInside)
        closeButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(closeButton);
    }

    // ライブラリから写真を選択する
    @objc func pickImageFromLibrary(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = UIImagePickerController.SourceType.photoLibrary
            controller.modalPresentationStyle = UIModalPresentationStyle.popover
            controller.popoverPresentationController?.sourceView = self.view
            controller.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
            self.present(controller, animated: true, completion: nil)
        }
    }
    // imagePicker popoverの大きさ指定
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }

    // 写真を選択した時に呼ばれる
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if info[UIImagePickerController.InfoKey.originalImage.rawValue] != nil {
            let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage


            let episodeID = appDelegate.SelectedIC?["EpisodeID"].asInt
            let icID = appDelegate.SelectedIC?["ICID"].asInt
            let seqNo = appDelegate.SelectedIC?["SEQNO"].asInt

            let imageData = image.jpegData(compressionQuality: 0.1)
            let fileString = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)

            let url = "\(AppConst.URLPrefix)ic/PostICPhotoFile"
            let params: [String: AnyObject] = [
                "EpisodeID": episodeID! as AnyObject,
                "ICID": icID! as AnyObject,
                "SEQNO": seqNo! as AnyObject,
                "extention": "jpg" as AnyObject,
                "fileData": fileString as AnyObject,
                ]
            let res = appCommon.postSynchronous(url, params: params)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の登録に失敗しました。")
            }
        }
        self.viewWillAppear(false)
        picker.dismiss(animated: true, completion: nil)
    }
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        // Status Barの高さを取得をする.
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        let barHeight = statusBarHeight + navBarHeight!

        // 写真アセスメントを全て取得する
        let episodeID = appDelegate.SelectedIC?["EpisodeID"].asInt
        let icID = appDelegate.SelectedIC?["ICID"].asInt
        let seqNo = appDelegate.SelectedIC?["SEQNO"].asInt
        ICPhotoFileList = icCommon.getICPhotoFileList(episodeID: episodeID!, icID: icID!, seqNo: seqNo!)

        // 一旦全てのボタンを削除する
        for i in 0 ..< subViewButtons.count {
            subViewButtons[i].removeFromSuperview()
        }
        subViewButtons = [] // 初期化
        selectedSeqNo = nil
        // 写真ボタンの追加
        let haba : CGFloat = 100 // ボタンを動かす幅
        let centerX : CGFloat = (navBarWidth!/2)
        var x : CGFloat
        var y : CGFloat = barHeight + 450 + 35
        if ICPhotoFileList != nil {
            for i in 0 ..< ICPhotoFileList!.length {
                if i >= 10 {
                    break
                }
                let trn = ICPhotoFileList![i]
                let seqNo = trn["PhotoSEQNO"].asInt!
                let count = i < 5 ? i : i - 5
                x = centerX + ((CGFloat(count) - 2) * haba)
                // UIボタンを作成.
                let button = UIButton(frame: CGRect(x: 0,y: 0,width: 70,height: 30))
                button.addTarget(self, action: #selector(DetailICPhoto.onClickPhotoButton(_:)), for: .touchUpInside)
                button.setTitle("写真\(i+1)", for: UIControl.State())
                if i == 0 { // 一つ目が選択状態
                    button.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
                    selectedSeqNo = seqNo
                } else {
                    button.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))
                }
                button.layer.position = CGPoint(x: x, y: y)
                button.setTitleColor(UIColor.textBlue(), for: UIControl.State())
                button.setTitleColor(UIColor.textBlue().withAlphaComponent(0.3), for: .highlighted)
                button.tag = trn["PhotoSEQNO"].asInt!

                // UIボタンをViewに追加.
                self.view.addSubview(button);
                // あとで削除するため保存する
                subViewButtons.append(button)
                if i == 4 { // 次の段
                    y += 50
                }
            }
        }
        if selectedSeqNo != nil {
            // ファイルの取得
            let uiButton = UIButton()
            uiButton.tag = selectedSeqNo!
            onClickPhotoButton(uiButton)
        } else {
            let image = UIImage(named: "noimage.jpg")
            imageView.image = image
            buttonDelete.isEnabled = false
            buttonAllDelete.isEnabled = false
        }
    }

    /*
     写真ボタンクリックイベント.
     */
    @objc func onClickPhotoButton(_ sender: UIButton) {
        print("onClickPhotoButton")
        print(sender.tag)
        // tagにSEQNOが設定されている
        selectedSeqNo = sender.tag

        for i in 0 ..< subViewButtons.count {
            if subViewButtons[i].tag == selectedSeqNo { // 選択状態
                subViewButtons[i].titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
            } else {
                subViewButtons[i].titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))
            }
        }

        // ファイルの取得
        let episodeID = appDelegate.SelectedIC?["EpisodeID"].asInt
        let icID = appDelegate.SelectedIC?["ICID"].asInt
        let seqNo = appDelegate.SelectedIC?["SEQNO"].asInt

        let url = "\(AppConst.URLPrefix)ic/GetICPhotoFileBase64String/\(episodeID!)/\(icID!)/\(seqNo!)/\(selectedSeqNo!)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の取得に失敗しました。")
            return
        }
        let decodedData = Data(base64Encoded: res.result! as String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        var image : UIImage!
        if decodedData != nil && (decodedData?.count)! > 0 {
            image = UIImage(data: decodedData!)
            buttonDelete.isEnabled = true
            buttonAllDelete.isEnabled = true
        } else {
            image = UIImage(named: "noimage.jpg")
            buttonDelete.isEnabled = false
            buttonAllDelete.isEnabled = false
        }
        imageView.image = image
    }
    // 削除ボタン
    @IBAction func ClickDelete(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "確認", message: "写真を削除しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("pushed 削除 Button")
            // アセスメント削除
            let episodeID = self.appDelegate.SelectedIC?["EpisodeID"].asInt
            let icID = self.appDelegate.SelectedIC?["ICID"].asInt
            let seqNo = self.appDelegate.SelectedIC?["SEQNO"].asInt
            let res = self.icCommon.deleleICPhotoFile(episodeID: episodeID!, icID: icID!, seqNo: seqNo!, photoSeqNo: self.selectedSeqNo)
            if AppCommon.isNilOrEmpty(res.errCode) {
                // 戻る
                self.viewWillAppear(false)
            } else {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の削除に失敗しました。")
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("キャンセル")
        })

        // addActionした順に左から右にボタンが配置
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)

    }
    // 全て削除ボタン
    @IBAction func ClickAllDelete(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "確認", message: "本当に全ての写真を削除しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "削除", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("pushed 削除 Button")
            // アセスメント削除
            let episodeID = self.appDelegate.SelectedIC?["EpisodeID"].asInt
            let icID = self.appDelegate.SelectedIC?["ICID"].asInt
            let seqNo = self.appDelegate.SelectedIC?["SEQNO"].asInt
            let res = self.icCommon.deleleICPhotoFile(episodeID: episodeID!, icID: icID!, seqNo: seqNo!)
            if AppCommon.isNilOrEmpty(res.errCode) {
                // 戻る
                self.viewWillAppear(false)
            } else {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の削除に失敗しました。")
            }
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
            print("キャンセル")
        })

        // addActionした順に左から右にボタンが配置
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }


    /*
     撮影ボタンクリック
     */
    @objc func ClickCamera(_ sender: AnyObject) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized,.notDetermined:
            performSegue(withIdentifier: "SegueICCamera",sender: self)
        case .denied:
            AppCommon.alertMessage(controller: self, title: "エラー", message: "カメラへのアクセスが許可されていません。")
        case .restricted:
            break
        }
    }
}
