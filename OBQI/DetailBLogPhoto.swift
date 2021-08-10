//
//  DetailBLogPhoto.swift
//  OBQI
//
//  Created by t.o on 2017/03/21.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailBLogPhoto: PhotoBaseController {
    let bLogCommon = BLogCommon()

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buttonDelete: UIBarButtonItem!
    @IBOutlet weak var buttonAllDelete: UIBarButtonItem!

    let photoButton = UIButton(frame: CGRect(x: 0,y: 0,width: 180,height: 50))

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
        selectButton.addTarget(self, action: #selector(PhotoBaseController.pickImageFromLibrary(_:)), for: .touchUpInside)
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
        closeButton.addTarget(self, action: #selector(PhotoBaseController.ClickCamera(_:)), for: .touchUpInside)
        closeButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(closeButton);
    }

    override func viewWillAppear(_ animated: Bool) {
        // シェーマから遷移してきた場合は、実施指示画面でDTの内容が書き換わる可能性を考慮し、partsNoからDT情報再取得
        if appDelegate.SelectedBLogImgPartsNo != nil {
            let selectedMstBusinessLogDT = appDelegate.MstBusinessLogDTList?
                .filter{
                    $0.1["BLogGroupID"].asInt! == super.appDelegate.SelectedBLogSub.BLogGroupID!
                        && $0.1["BLogSubGroupID"].asInt! == super.appDelegate.SelectedBLogSub.BLogSubGroupID!
                        && $0.1["ImgPartsNo"].asInt! == appDelegate.SelectedBLogImgPartsNo
                        && $0.1["BLogInputKB"].asString! == AppConst.InputKB.PHOTO.rawValue
                }.first.map{ $0.1 }

            super.appDelegate.SelectedBLogDT = AppConst.BLogDTFormat(
                BLogGroupID: selectedMstBusinessLogDT?["BLogGroupID"].asInt!,
                BLogSubGroupID: selectedMstBusinessLogDT?["BLogSubGroupID"].asInt!,
                BLogItemID: selectedMstBusinessLogDT?["BLogItemID"].asInt!
            )
        }

        super.viewWillAppear(animated)

        // シェーマ区分取得
        let selectedSchemaKBString = appDelegate.MstBusinessLogSubHDList?
            .filter{ $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogGroupID && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogSub.BLogSubGroupID }
            .first.map{ $0.1["SchemaKB"].asString! }
        let selectedSchemaKB = AppConst.SchemaKB(rawValue: selectedSchemaKBString!)

        // 変更があった場合
        if appDelegate.BLogisChanged {
            // 択一選択の場合は選択されたパーツ以外の情報を削除
            switch selectedSchemaKB! {
            case .SINGLE, .SINGLE_REQUIRE_PHOTO, .ONLY_SCHEMA_PHOTO_SINGLE_REQUIRE_PHOTO:
                // 選択中のアイテム以外は全削除
                // 未登録状態なら削除の必要なし
                if appDelegate.trnBLogDTList == nil {
                    return
                }

                let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)

                appDelegate.trnBLogDTList?.forEach{
                    // 選択中パーツは削除しない
                    let ignoreItem = appDelegate.SelectedBLogDT.BLogItemID
                    if ignoreItem != nil && $0.1["BLogItemID"].asInt! == ignoreItem! {
                        return
                    }

                    let selectedBLog = AppConst.BLogDTFormat(
                        BLogGroupID: $0.1["BLogGroupID"].asInt!,
                        BLogSubGroupID: $0.1["BLogSubGroupID"].asInt!,
                        BLogItemID: $0.1["BLogItemID"].asInt!
                    )

                    let bLogSeqNo = appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!

                    let res = bLogCommon.delBLog(customerID, selectedBLog: selectedBLog, bLogSeqNo: bLogSeqNo)

                    if !AppCommon.isNilOrEmpty(res.errCode) {
                        AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
                    }
                }

                // BLogDT一覧取得
                let bLogGroupID = appDelegate.trnBLogSubHD?["BLogGroupID"].asInt!
                let bLogSubGroupID = appDelegate.trnBLogSubHD?["BLogSubGroupID"].asInt!
                let bLogSeqNo = appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!

                let resDT = bLogCommon.getBLogDTList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID, bLogSeqNo: bLogSeqNo)
                
                if !AppCommon.isNilOrEmpty(resDT.result) {
                    appDelegate.trnBLogDTList = JSON(string: resDT.result!) // JSON読み込み
                }
                
                break
                
            default: break
            }
            
            // フラグを戻す
            appDelegate.BLogisChanged = false
        }

        // 実施指示ボタン描画
        // シェーマあり択一（写真必須）、シェーマあり複数（写真必須）
        if super.appDelegate.trnBLogDTList != nil && (selectedSchemaKB == AppConst.SchemaKB.SINGLE_REQUIRE_PHOTO || selectedSchemaKB == AppConst.SchemaKB.MULTI_REQUIRE_PHOTO) {
            // 一旦削除
            photoButton.removeFromSuperview()

            // 実施指示画面へ遷移するには画像登録が必須
            if (super.appDelegate.trnBLogDTList?.contains{ $0.1["BLogItemID"].asInt! == super.appDelegate.SelectedBLogDT.BLogItemID })! {
                // Viewの高さと幅を取得する.
                let displayHeight: CGFloat = self.view.frame.height
                // Status Barの高さを取得をする.
                let navBarWidth = self.navigationController?.navigationBar.frame.size.width
                // UIボタンを作成.
                photoButton.backgroundColor = UIColor.photoViewButton()
                photoButton.layer.masksToBounds = true
                photoButton.setTitle("実施指示入力", for: UIControl.State())
                photoButton.layer.cornerRadius = 10.0
                photoButton.layer.position = CGPoint(x: (navBarWidth!/2)+200, y:displayHeight-50)
                photoButton.addTarget(self, action: #selector(DetailAssPhoto.ClickInputList(_:)), for: .touchUpInside)
                photoButton.setTitleColor(UIColor.gray, for: .highlighted)
                // UIボタンをViewに追加.
                self.view.addSubview(photoButton)
            }
        }
    }

    // 削除ボタン
    @IBAction func ClickDelete(_ sender: AnyObject) {
        // アラートアクションの設定
        var actionList = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()

        // キャンセルアクション
        actionList.append(
            (
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
            })
        )

        // OKアクション
        actionList.append(
            (
                title: "OK",
                style: UIAlertAction.Style.default,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Save")

                    // 削除
                    let customerID = Int(super.appDelegate.SelectedCustomer!["CustomerID"].asString!)
                    let bLogSeqNo = super.appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!

                    let res = self.bLogCommon.delBLog(customerID, selectedBLog: super.appDelegate.SelectedBLogDT, bLogSeqNo: bLogSeqNo, SeqNo: super.selectedSeqNo!)

                    if AppCommon.isNilOrEmpty(res.errCode) {
                        // BLogDT一覧取得
                        let bLogGroupID = super.appDelegate.trnBLogSubHD?["BLogGroupID"].asInt!
                        let bLogSubGroupID = super.appDelegate.trnBLogSubHD?["BLogSubGroupID"].asInt!
                        let resDT = self.bLogCommon.getBLogDTList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID, bLogSeqNo: super.appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!)

                        if !AppCommon.isNilOrEmpty(resDT.result) {
                            super.appDelegate.trnBLogDTList = JSON(string: resDT.result!) // JSON読み込み
                        }
                        
                        // 変更フラグ
                        super.appDelegate.BLogisChanged = true

                        // 再描画
                        self.viewWillAppear(false)

                    } else {
                        AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の削除に失敗しました。")
                    }
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "写真を削除しますか？", actionList: actionList)
    }

    // 全て削除ボタン
    @IBAction func ClickAllDelete(_ sender: AnyObject) {
        // アラートアクションの設定
        var actionList = [(title: String , style: UIAlertAction.Style ,action: (UIAlertAction) -> Void)]()

        // キャンセルアクション
        actionList.append(
            (
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Cancel")
            })
        )

        // OKアクション
        actionList.append(
            (
                title: "OK",
                style: UIAlertAction.Style.default,
                action: {
                    (action: UIAlertAction!) -> Void in
                    print("Save")

                    // 削除
                    let customerID = Int(super.appDelegate.SelectedCustomer!["CustomerID"].asString!)
                    let bLogSeqNo = super.appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!

                    let res = self.bLogCommon.delBLog(customerID, selectedBLog: super.appDelegate.SelectedBLogDT, bLogSeqNo: bLogSeqNo)
                    if AppCommon.isNilOrEmpty(res.errCode) {
                        // BLogDT一覧取得
                        let bLogGroupID = super.appDelegate.trnBLogSubHD?["BLogGroupID"].asInt!
                        let bLogSubGroupID = super.appDelegate.trnBLogSubHD?["BLogSubGroupID"].asInt!
                        let resDT = self.bLogCommon.getBLogDTList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID, bLogSeqNo: super.appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!)

                        if !AppCommon.isNilOrEmpty(resDT.result) {
                            super.appDelegate.trnBLogDTList = JSON(string: resDT.result!) // JSON読み込み
                        }

                        // 変更フラグ
                        super.appDelegate.BLogisChanged = true

                        // 再描画
                        self.viewWillAppear(false)

                    } else {
                        AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の削除に失敗しました。")
                    }
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "本当に全ての写真を削除しますか？", actionList: actionList)
    }

    func ClickInputList(_ sender: AnyObject) {
        // 実施日付
        appDelegate.inputTreatmentDateTime = AppCommon.getDateFormat(date: Date(), format: "yyyy/MM/dd HH:mm")
        // 遷移
        performSegue(withIdentifier: "SegueDetailBLogList",sender: self)
    }
}

// 抽象メソッドの実装
extension DetailBLogPhoto: PhotoProtocol {
    /*
     画像全件取得
     */
    func getPhotoFileList() -> [JSON?] {
        // 新規登録 or 画像がない場合はnil
        if super.appDelegate.trnBLogDTList == nil {
            return []
        }

        return super.appDelegate.trnBLogDTList!.filter{ $0.1["BLogItemID"].asInt! == super.appDelegate.SelectedBLogDT.BLogItemID! }.map{ $0.1 }
    }

    /*
     表示する画像を変更
     */
    func showPhoto(seq: Int?) {
        var image = UIImage(named: "noimage.jpg")
        var isEnabled = false

        if seq != nil {
            // 選択されたら太字
            subViewButtons.forEach{
                $0.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))

                if $0.tag == seq! {
                    $0.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
                }
            }

            // リストの中から選択されたtrnBLogDTを特定
            let trnBLogDT = super.appDelegate.trnBLogDTList?
                .filter{
                    $0.1["BLogItemID"].asInt! == super.appDelegate.SelectedBLogDT.BLogItemID
                    && $0.1["SEQNO"].asInt! == seq
                }.first.map{ $0.1 }

            // ファイルの取得
            let customerID = Int(super.appDelegate.SelectedCustomer!["CustomerID"].asString!)
            let bLogGroupID = trnBLogDT?["BLogGroupID"].asInt!
            let bLogSubGroupID = trnBLogDT?["BLogSubGroupID"].asInt!
            let bLogSeqNo = trnBLogDT?["BLogSEQNO"].asInt!
            let bLogItemID = trnBLogDT?["BLogItemID"].asInt!
            let seqNo = trnBLogDT?["SEQNO"].asInt!

            let url = "\(AppConst.URLPrefix)business/GetBssPhotoFileBase64String/\(customerID!)/\(bLogGroupID!)/\(bLogSubGroupID!)/\(bLogSeqNo!)/\(bLogItemID!)/\(seqNo!)"
            let res = appCommon.getSynchronous(url)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の取得に失敗しました。")
                return
            }
            let decodedData = Data(base64Encoded: res.result! as String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)

            // デコードしきれたら画像をセット
            if decodedData != nil && (decodedData?.count)! > 0 {
                image = UIImage(data: decodedData!)
                isEnabled = true
            }
        }

        imageView.image = image
        buttonDelete.isEnabled = isEnabled
        buttonAllDelete.isEnabled = isEnabled
    }

    /*
     画像を保存
     */
    func savePhoto(fileString: String) {
        let customerID = Int(super.appDelegate.SelectedCustomer!["CustomerID"].asString!)
        let bLogGroupID = appDelegate.SelectedBLogDT.BLogGroupID!
        let bLogSubGroupID = appDelegate.SelectedBLogDT.BLogSubGroupID!

        // trn情報がない場合、新規登録
        var bLogSeqNo:Int?
        var treatmentDateTime:String?

        let isCreate = appDelegate.trnBLogSubHD == nil
        if isCreate {
            treatmentDateTime = appDelegate.inputTreatmentDateTime!
        } else {
            bLogSeqNo = appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!
        }

        let res = bLogCommon.regPhoto(customerID, selectedBLog: appDelegate.SelectedBLogDT, fileString: fileString, bLogSeqNo: bLogSeqNo, treatmentDateTime: treatmentDateTime)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "写真の登録に失敗しました。")
        }

        // 新規登録の場合はHDをセット
        if !AppCommon.isNilOrEmpty(res.result) && isCreate {
            // BLogSubHD一覧取得
            let resSubHD = bLogCommon.getBLogSubHDList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID)

            if !AppCommon.isNilOrEmpty(resSubHD.result) {
                let trnBLogSubHDJson = JSON(string: resSubHD.result!).map{ $0.1 } // JSON読み込み
                appDelegate.trnBLogSubHD = trnBLogSubHDJson.last
            }
        }

        // BLogDT一覧取得
        let resDT = bLogCommon.getBLogDTList(customerID, bLogGroupID: bLogGroupID, bLogSubGroupID: bLogSubGroupID, bLogSeqNo: appDelegate.trnBLogSubHD?["BLogSEQNO"].asInt!)

        if !AppCommon.isNilOrEmpty(resDT.result) {
            appDelegate.trnBLogDTList = JSON(string: resDT.result!) // JSON読み込み
        }

        // 変更フラグ
        appDelegate.BLogisChanged = true

        // Post Notification（送信）
        let center = NotificationCenter.default
        center.post(name: appDelegate.BLogNotificationName, object: nil)
    }
}
