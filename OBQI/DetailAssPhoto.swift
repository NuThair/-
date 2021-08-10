//
//  DetailAssPhoto.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/11.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit
import AVFoundation

class DetailAssPhoto: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // 対象のアセスメント
    //var assMster : JSON?
    // 入力値
    var inputAssList : JSON?
    // シェーマがあるか
    var noSchema = false
    // 写真アセスメントのリスト
    var trnAssessmentList : JSON?
    // アセスメント入力へボタン
    var isButtonEnable = false
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let assCommon = AssCommon()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonDelete: UIBarButtonItem!
    @IBOutlet weak var buttonAllDelete: UIBarButtonItem!

    // 写真ボタンを入れる
    var subViewButtons : [UIButton] = []
    // 選択されているSEQNO
    var selectedSeqNo : Int?
    // 画面表示時に写真が1つ以上あるか？
    var existsPhotoOnStart = false
    let photoButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
    
    let appCommon = AppCommon()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Viewの高さと幅を取得する.
        let displayHeight: CGFloat = self.view.frame.height
        // Status Barの高さを取得をする.
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        // シェーマ区分がカメラのみ択一とカメラのみ複数の場合はボタンを表示しない
        let schemaKb = appDelegate.SelectedMstAssessmentSubGroup!["SchemaKB"].asString!
        if schemaKb == AppConst.SchemaKB.NO_SCHEMA.rawValue {
            noSchema = true
        }

        // UIボタンを作成.
        let selectButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
        selectButton.backgroundColor = UIColor.photoViewButton()
        selectButton.layer.masksToBounds = true
        selectButton.setTitle("写真選択", for: UIControl.State())
        selectButton.layer.cornerRadius = 10.0
        selectButton.layer.position = CGPoint(x: (navBarWidth!/2), y:displayHeight-50)
        selectButton.addTarget(self, action: #selector(DetailAssPhoto.pickImageFromLibrary(_:)), for: .touchUpInside)
        selectButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(selectButton);
        // UIボタンを作成.
        let closeButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))
        closeButton.backgroundColor = UIColor.photoViewButton()
        closeButton.layer.masksToBounds = true
        closeButton.setTitle("部位撮影", for: UIControl.State())
        closeButton.layer.cornerRadius = 10.0
        closeButton.layer.position = CGPoint(x: (navBarWidth!/2)-200, y:displayHeight-50)
        closeButton.addTarget(self, action: #selector(DetailAssPhoto.ClickCamera(_:)), for: .touchUpInside)
        closeButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(closeButton);

        // 完了している場合、ボタン押せない
        if appDelegate.SelectedAssHD!["AssRecordKB"].asString == AppConst.AssRecordKB.COMP.rawValue
        {
            selectButton.isEnabled = false
            selectButton.backgroundColor = UIColor.lightGray
            closeButton.isEnabled = false
            closeButton.backgroundColor = UIColor.lightGray
        }

        // ロード時に写真があるかどうか確認する
        existsPhotoOnStart = assCommon.getPhotoAssessmentList() == nil
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
        if appDelegate.SelectedAssHD!["AssRecordKB"].asString == AppConst.AssRecordKB.COMP.rawValue
        { // 完了している場合は更新しない
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        
        if info[UIImagePickerController.InfoKey.originalImage.rawValue] != nil {
            let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as! UIImage
            //imageView.image = image
            
            let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
            let assID = appDelegate.SelectedAssAssID!
            let menuGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuGroupID"].asInt!
            let menuSubGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuSubGroupID"].asInt!
            let assessmentID = appDelegate.SelectedMstAssessmentItem!["AssItemID"].asInt!
            let imageData = image.jpegData(compressionQuality: 0.1)
            let fileString = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
            
            let url = "\(AppConst.URLPrefix)assessment/PostAssPhotoFile"
            let params: [String: AnyObject] = [
                "assID": assID as AnyObject,
                "customerID": customerID as AnyObject,
                "assMenuGroupID": String(menuGroupID) as AnyObject,
                "assMenuSubGroupID": String(menuSubGroupID) as AnyObject,
                "itemID": String(assessmentID) as AnyObject,
                "extention": "jpg" as AnyObject,
                "fileData": fileString as AnyObject,
                ]
            let res = appCommon.postSynchronous(url, params: params)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の登録に失敗しました。")
            } else {
                // フラグ更新
                appDelegate.ChangeInputAssFlagForShcema = true
                appDelegate.ChangeInputAssFlagForList = true

                // Post Notification（送信）
                let center = NotificationCenter.default
                center.post(name: NSNotification.Name(rawValue: "requiredAssSubList"), object: nil)
            }
            // シェーマ区分が
            //let schemaKb = appDelegate.SelectedMstAssessmentSubGroup!["SchemaKB"].asString!
        }
        picker.dismiss(animated: true, completion: nil)
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        // Viewの高さと幅を取得する.
        //let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        // Status Barの高さを取得をする.
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        let barHeight = statusBarHeight + navBarHeight!
        
        // 写真アセスメントを全て取得する
        trnAssessmentList = assCommon.getPhotoAssessmentList()
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
        //for var i = 0; i < trnAssessmentList?.length && i < 10; i += 1 {
        if trnAssessmentList != nil {
            for i in 0 ..< trnAssessmentList!.length {
                if i >= 10 {
                    break
                }
                let trn = trnAssessmentList![i]
                let seqNo = trn["SEQNO"].asInt!
                let count = i < 5 ? i : i - 5
                x = centerX + ((CGFloat(count) - 2) * haba)
                // UIボタンを作成.
                let button = UIButton(frame: CGRect(x: 0,y: 0,width: 70,height: 30))
                button.addTarget(self, action: #selector(DetailAssPhoto.onClickPhotoButton(_:)), for: .touchUpInside)
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
                button.tag = trn["SEQNO"].asInt!

                // UIボタンをViewに追加.
                self.view.addSubview(button);
                // あとで削除するため保存する
                subViewButtons.append(button)
                if i == 4 { // 次の段
                    y += 50
                }
            }
        }
        var existsPhoto = false
        if selectedSeqNo != nil {
            existsPhoto = true
            // ファイルの取得
            let uiButton = UIButton()
            uiButton.tag = selectedSeqNo!
            onClickPhotoButton(uiButton)
        } else {
            existsPhoto = false
            let image = UIImage(named: "noimage.jpg")
            imageView.image = image
            buttonDelete.isEnabled = false
            buttonAllDelete.isEnabled = false
        }
        // シェーマ区分が　シェーマのみ写真複数選択（写真必須）
        let schemaKb = appDelegate.SelectedMstAssessmentSubGroup!["SchemaKB"].asString!
        
        if schemaKb == AppConst.SchemaKB.MULTI_REQUIRE_PHOTO.rawValue { // シェーマあり複数選択（写真必須）
            let assMenuGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
            let assMenuSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
            let imgPartsNo = appDelegate.SelectedAssImagePartsNo
            if existsPhoto != existsPhotoOnStart {
                existsPhotoOnStart = existsPhoto // フラグを変更
                if existsPhoto { // 1枚目の写真をとった
                    // アセスを登録の登録は行わない
                } else if !existsPhoto { // 写真を全て削除した
                    // 全部のアセスを削除する
                    //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
                    for i in 0 ..< appDelegate.MstAssessmentList!.length {
                        let tmpAssMenuGroupID = appDelegate.MstAssessmentList?[i]["AssMenuGroupID"].asInt
                        let tmpAssMenuSubGroupID = appDelegate.MstAssessmentList?[i]["AssMenuSubGroupID"].asInt
                        let tmpImgPartsNo = appDelegate.MstAssessmentList?[i]["ImgPartsNo"].asInt
                        
                        if tmpAssMenuGroupID == assMenuGroupID
                            && tmpAssMenuSubGroupID == assMenuSubGroupID
                            && tmpImgPartsNo == imgPartsNo {
                            let choices = appDelegate.MstAssessmentList?[i]["AssChoices"].asString
                            let choiceStrArray = choices?.components(separatedBy: ",")
                            if (choiceStrArray?.count)! > 0 {
                                let firstChoice = choiceStrArray?[0]
                                var choiceArray : [AnyObject] = []
                                choiceArray.append(firstChoice! as AnyObject)
                                let res = assCommon.delAss(appDelegate.SelectedAssAssID!, selectedAss: appDelegate.MstAssessmentList?[i], isSync: false)
                                if !AppCommon.isNilOrEmpty(res.errCode) {
                                    AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                                }
                            }
                        }
                    }
                }
            }
        }
        else if schemaKb == AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_MULTI_REQUIRE_PHOTO.rawValue { // シェーマのみ写真複数選択（写真必須）
            let assMenuGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
            let assMenuSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
            let imgPartsNo = appDelegate.SelectedAssImagePartsNo
            if existsPhoto != existsPhotoOnStart {
                existsPhotoOnStart = existsPhoto // フラグを変更
                if existsPhoto { // 1枚目の写真をとった
                    // アセスを登録する
                    //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
                    for i in 0 ..< appDelegate.MstAssessmentList!.length {
                        let mst = appDelegate.MstAssessmentList![i]
                        let tmpAssMenuGroupID = mst["AssMenuGroupID"].asInt
                        let tmpAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt
                        let tmpImgPartsNo = mst["ImgPartsNo"].asInt
                        let tmpAssInputKB = mst["AssInputKB"].asString!
                        // カメラ以外
                        if tmpAssMenuGroupID == assMenuGroupID
                            && tmpAssMenuSubGroupID == assMenuSubGroupID
                            && tmpImgPartsNo == imgPartsNo {
                            if tmpAssInputKB != AppConst.InputKB.PHOTO.rawValue {
                                let choices = mst["AssChoices"].asString
                                if AppCommon.isNilOrEmpty(choices) {
                                    continue
                                }
                                let choiceStrArray = choices?.components(separatedBy: ",")
                                let firstChoice = choiceStrArray?[0]
                                var choiceArray : [AnyObject] = []
                                choiceArray.append(firstChoice! as AnyObject)
                                let res = assCommon.regAss(choiceArray, assessmentID: appDelegate.SelectedAssAssID!, selectedAss: mst, isSync: false)
                                if !AppCommon.isNilOrEmpty(res.errCode) {
                                    AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                                }
                            }
                        }
                    }
                } else if !existsPhoto { // 写真を全て削除した
                    // 全部のアセスを削除する
                    //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
                    for i in 0 ..< appDelegate.MstAssessmentList!.length {
                        let tmpAssMenuGroupID = appDelegate.MstAssessmentList?[i]["AssMenuGroupID"].asInt
                        let tmpAssMenuSubGroupID = appDelegate.MstAssessmentList?[i]["AssMenuSubGroupID"].asInt
                        let tmpImgPartsNo = appDelegate.MstAssessmentList?[i]["ImgPartsNo"].asInt
                        
                        if tmpAssMenuGroupID == assMenuGroupID
                            && tmpAssMenuSubGroupID == assMenuSubGroupID
                            && tmpImgPartsNo == imgPartsNo {
                            let choices = appDelegate.MstAssessmentList?[i]["AssChoices"].asString
                            let choiceStrArray = choices?.components(separatedBy: ",")
                            if (choiceStrArray?.count)! > 0 {
                                let firstChoice = choiceStrArray?[0]
                                var choiceArray : [AnyObject] = []
                                choiceArray.append(firstChoice! as AnyObject)
                                let res = assCommon.delAss(appDelegate.SelectedAssAssID!, selectedAss: appDelegate.MstAssessmentList?[i], isSync: false)
                                if !AppCommon.isNilOrEmpty(res.errCode) {
                                    AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if !isButtonEnable {
            // シェーマ区分がカメラのみ択一とカメラのみ複数の場合はボタンを表示しない
            if schemaKb != AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_SINGLE.rawValue && schemaKb != AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_MULTI.rawValue && schemaKb != AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_SINGLE_REQUIRE_PHOTO.rawValue && schemaKb != AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_MULTI_REQUIRE_PHOTO.rawValue && schemaKb != AppConst.SchemaKB.NO_SCHEMA.rawValue && !(!existsPhoto && schemaKb == AppConst.SchemaKB.MULTI_REQUIRE_PHOTO.rawValue) {
                // UIボタンを作成.
                photoButton.backgroundColor = UIColor.photoViewButton()
                photoButton.layer.masksToBounds = true
                photoButton.setTitle("アセスメント入力", for: UIControl.State())
                photoButton.layer.cornerRadius = 10.0
                photoButton.layer.position = CGPoint(x: (navBarWidth!/2)+200, y:displayHeight-50)
                photoButton.addTarget(self, action: #selector(DetailAssPhoto.ClickInputList(_:)), for: .touchUpInside)
                photoButton.setTitleColor(UIColor.gray, for: .highlighted)
                // UIボタンをViewに追加.
                self.view.addSubview(photoButton);
                isButtonEnable = true
            }
        } else {
            if !existsPhoto && schemaKb == AppConst.SchemaKB.MULTI_REQUIRE_PHOTO.rawValue {
                photoButton.removeFromSuperview()
                isButtonEnable = false
            }
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
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let assID = appDelegate.SelectedAssAssID!
        let menuGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuGroupID"].asInt!
        let menuSubGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuSubGroupID"].asInt!
        let assessmentID = appDelegate.SelectedMstAssessmentItem!["AssItemID"].asInt!
        
        let url = "\(AppConst.URLPrefix)assessment/GetAssPhotoFileBase64String/\(customerID)/\(assID)/\(menuGroupID)/\(menuSubGroupID)/\(assessmentID)/\(selectedSeqNo!)"
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
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
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
            let res = self.assCommon.delAss(self.appDelegate.SelectedAssAssID!, selectedAss: self.appDelegate.SelectedMstAssessmentItem, isSync: true, seqNo: self.selectedSeqNo)
            if AppCommon.isNilOrEmpty(res.errCode) {
                self.appDelegate.ChangeInputAssFlagForShcema = true
                self.appDelegate.ChangeInputAssFlagForList = true
                // 戻る
                self.viewWillAppear(false)

                // Post Notification（送信）
                let center = NotificationCenter.default
                center.post(name: NSNotification.Name(rawValue: "requiredAssSubList"), object: nil)
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
            // 一括削除
            let res = self.assCommon.delAss(self.appDelegate.SelectedAssAssID!, selectedAss: self.appDelegate.SelectedMstAssessmentItem, isSync: true)
            if AppCommon.isNilOrEmpty(res.errCode) {
                self.appDelegate.ChangeInputAssFlagForShcema = true
                self.appDelegate.ChangeInputAssFlagForList = true
                // 戻る
                self.viewWillAppear(false)

                // Post Notification（送信）
                let center = NotificationCenter.default
                center.post(name: NSNotification.Name(rawValue: "requiredAssSubList"), object: nil)
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
    
    @objc func ClickInputList(_ sender: AnyObject) {
        // 遷移
        performSegue(withIdentifier: "SegueAssInputList",sender: self)
    }
    @objc func ClickCamera(_ sender: AnyObject) {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized,.notDetermined:
            performSegue(withIdentifier: "SegueAssCamera",sender: self)
        case .denied:
            AppCommon.alertMessage(controller: self, title: "エラー", message: "カメラへのアクセスが許可されていません。")
        case .restricted:
            break
        }
    }
    /*
     戻る
     */
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        super.viewWillDisappear(animated)
    }
    
}
