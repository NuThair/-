//
//  DetailAssVideo.swift
//  OBQI
//
//  Created by t.o on 2017/06/07.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class DetailAssVideo: UIViewController {
    // 入力値
    var inputAssList : JSON?
    // シェーマがあるか
    var noSchema = false
    // アセスメント入力へボタン
    var isButtonEnable = false

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let assCommon = AssCommon()

    // 再生用のアイテム.
    var playerItem : AVPlayerItem!

    // AVPlayer.
    var videoPlayer : AVPlayer!

    // 動画データリスト
    var videoFileList:[JSON?] = []

    // 選択中の動画
    var selectedSeqNo:Int?

    // 動画切り替えボタン
    var subViewButtons:[UIButton] = []

    @IBOutlet weak var myContainer: UIView!
    @IBOutlet weak var buttonDelete: UIBarButtonItem!
    @IBOutlet weak var buttonAllDelete: UIBarButtonItem!

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
        selectButton.setTitle("動画撮影", for: UIControl.State())
        selectButton.layer.cornerRadius = 10.0
        selectButton.layer.position = CGPoint(x: (navBarWidth!/2), y:displayHeight-50)
        selectButton.addTarget(self, action: #selector(self.ClickVideoRec(_:)), for: .touchUpInside)
        selectButton.setTitleColor(UIColor.gray, for: .highlighted)
        // UIボタンをViewに追加.
        self.view.addSubview(selectButton);

        // 完了している場合、ボタン押せない
        if appDelegate.SelectedAssHD!["AssRecordKB"].asString == AppConst.AssRecordKB.COMP.rawValue
        {
            selectButton.isEnabled = false
            selectButton.backgroundColor = UIColor.lightGray
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // DBに登録されている動画を全て取得する
        // 新規登録 or 動画がない場合はnil
        let videoFileListJSON = assCommon.getPhotoAssessmentList()
        if videoFileListJSON != nil && (videoFileListJSON?.length)! > 0 {
            videoFileList = (videoFileListJSON?.map{ $0.1 })!
        }

        // Status Barの高さを取得をする.
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width

        // 一旦全てのボタンを削除する
        subViewButtons.forEach{
            $0.removeFromSuperview()
        }
        subViewButtons = [] // 初期化

        selectedSeqNo = nil
        // 動画ボタンの追加
        let haba : CGFloat = 100 // ボタンを動かす幅
        let centerX : CGFloat = (navBarWidth!/2)
        var x : CGFloat = 0
        var y : CGFloat = myContainer.bounds.height + 50

        // 10枚まで表示
        videoFileList.enumerated().filter{ $0.offset < 10 }.forEach{
            let seqNo = $0.element?["SEQNO"].asInt!

            // 5ずつで改行
            let surplus = $0.offset % 5
            if surplus == 0 {
                y += 50
            }

            // UIボタンを作成.
            let button = UIButton(frame: CGRect(x: 0,y: 0,width: 70,height: 30))
            button.addTarget(self, action: #selector(self.changeMovie(_:)), for: .touchUpInside)
            button.setTitle("動画\($0.offset + 1)", for: UIControl.State())

            button.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))
            if $0.offset == 0 { // 一つ目が選択状態
                button.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
                selectedSeqNo = seqNo

            }

            x = centerX + (CGFloat(surplus - 2) * haba)
            button.layer.position = CGPoint(x: x, y: y)
            button.setTitleColor(UIColor.textBlue(), for: UIControl.State())
            button.setTitleColor(UIColor.textBlue().withAlphaComponent(0.3), for: .highlighted)
            button.tag = seqNo!

            // UIボタンをViewに追加.
            self.view.addSubview(button);
            // あとで削除するため保存する
            subViewButtons.append(button)
        }

        let isEnabled = showMovie(seq: selectedSeqNo)

        buttonDelete.isEnabled = isEnabled
        buttonAllDelete.isEnabled = isEnabled
    }

    func displayContentController(content:UIViewController, container:UIView){
        addChild(content)
        content.view.frame = container.bounds
        container.addSubview(content.view)
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
                        AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "動画の削除に失敗しました。")
                    }
            })
        )

        AppCommon.alertAnyAction(controller: self, title: "確認", message: "動画を削除しますか？", actionList: actionList)
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
                        AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "動画の削除に失敗しました。")
                    }
            })
        )
        
        AppCommon.alertAnyAction(controller: self, title: "確認", message: "本当に全ての動画を削除しますか？", actionList: actionList)
    }

    // 動画撮影に必要なデバイスの使用許可を確認
    @objc func ClickVideoRec(_ sender: AnyObject) {
        // カメラ
        if !AppCommon.checkCameraAuthStatus(controller: self) {
            return
        }
        // マイク
        if !AppCommon.checkMicrophoneAuthStatus(controller: self) {
            return
        }

        // 遷移
        performSegue(withIdentifier: "SegueVideoRecord",sender: self)
    }


    /*
     動画ラベルクリックイベント.
     */
    @objc func changeMovie(_ sender: UIButton) {
        print("changeMovie")
        print(sender.tag)

        selectedSeqNo = sender.tag

        let isEnabled = showMovie(seq: sender.tag)

        buttonDelete.isEnabled = isEnabled
        buttonAllDelete.isEnabled = isEnabled
    }

    /*
     表示する動画を変更
     */
    func showMovie(seq: Int?) -> Bool {
        var isEnabled = false

        // 表示対象が存在しない場合代替画像を表示
        if seq == nil {
            let imageView = UIImageView(image: UIImage(named: "noimage.jpg"))
            imageView.frame = myContainer.bounds
            myContainer.addSubview(imageView)

            return isEnabled
        }

        // 選択されたら太字
        subViewButtons.forEach{
            $0.titleLabel!.font = UIFont(name: "Helvetica",size: CGFloat(20))

            if $0.tag == seq! {
                $0.titleLabel!.font = UIFont(name: "Helvetica-Bold",size: CGFloat(20))
            }
        }

        // ファイルの取得
        let customerID = appDelegate.SelectedCustomer!["CustomerID"].asString!
        let assID = appDelegate.SelectedAssAssID!
        let menuGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuGroupID"].asInt!
        let menuSubGroupID = appDelegate.SelectedMstAssessmentItem!["AssMenuSubGroupID"].asInt!
        let assessmentID = appDelegate.SelectedMstAssessmentItem!["AssItemID"].asInt!

        let url = "\(AppConst.URLPrefix)assessment/GetAssMovieFileBase64String/\(customerID)/\(assID)/\(menuGroupID)/\(menuSubGroupID)/\(assessmentID)/\(seq!)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "動画の取得に失敗しました。")
            return isEnabled
        }
        let decodedData = Data(base64Encoded: res.result! as String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)

        // デコードしきれたら画像をセット
        if decodedData != nil && (decodedData?.count)! > 0 {
            isEnabled = true

            // start recording
            let tmpPath = NSTemporaryDirectory()
            // ファイル名.
            let filePath = "\(tmpPath)tmp.mp4"
            // URL.
            let fileURL = URL(fileURLWithPath: filePath)

            // 一旦保存
            do {
                try decodedData?.write(to: fileURL)
            } catch let error as NSError {
                print("failed to write: \(error)")
            }


            let avAsset = AVURLAsset(url: fileURL)


            // AVPlayerに再生させるアイテムを生成.
            playerItem = AVPlayerItem(asset: avAsset)

            // AVPlayerを生成.
            videoPlayer = AVPlayer(playerItem: playerItem)

            let playerViewController = AVPlayerViewController()
            playerViewController.player = videoPlayer
            displayContentController(content: playerViewController, container: myContainer)
        }

        return isEnabled
    }
}
