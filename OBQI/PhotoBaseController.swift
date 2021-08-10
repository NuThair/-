//
//  CameraBaseController.swift
//  OBQI
//
//  Created by t.o on 2017/03/21.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit
import AVFoundation

class PhotoBaseController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var photoPrtocol:PhotoProtocol?

    // 写真データリスト
    var photoFileList:[JSON?] = []

    // 選択中の写真
    var selectedSeqNo:Int?

    // 写真切り替えボタン
    var subViewButtons:[UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // 子クラスで実装がおこなわれるメソッド群
        photoPrtocol = self as? PhotoProtocol
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        // DBに登録されている写真を全て取得する
        photoFileList = (photoPrtocol?.getPhotoFileList())!

        // Status Barの高さを取得をする.
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        let barHeight = statusBarHeight + navBarHeight!

        // 一旦全てのボタンを削除する
        subViewButtons.forEach{
            $0.removeFromSuperview()
        }
        subViewButtons = [] // 初期化

        selectedSeqNo = nil
        // 写真ボタンの追加
        let haba : CGFloat = 100 // ボタンを動かす幅
        let centerX : CGFloat = (navBarWidth!/2)
        var x : CGFloat = 0
        var y : CGFloat = barHeight + 400 + 35

        // 10枚まで表示
        photoFileList.enumerated().filter{ $0.offset < 10 }.forEach{
            let seqNo = $0.element?["SEQNO"].asInt!

            // 5ずつで改行
            let surplus = $0.offset % 5
            if surplus == 0 {
                y += 50
            }

            // UIボタンを作成.
            let button = UIButton(frame: CGRect(x: 0,y: 0,width: 70,height: 30))
            button.addTarget(self, action: #selector(PhotoBaseController.changePhoto(_:)), for: .touchUpInside)
            button.setTitle("写真\($0.offset + 1)", for: UIControl.State())

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

        // 画像を表示
        photoPrtocol?.showPhoto(seq: selectedSeqNo)
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

            let imageData = image.jpegData(compressionQuality: 0.1)
            let fileString = imageData!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)

            photoPrtocol?.savePhoto(fileString: fileString)
        }
        self.viewWillAppear(false)
        picker.dismiss(animated: true, completion: nil)
    }

    /*
     写真ラベルクリックイベント.
     */
    @objc func changePhoto(_ sender: UIButton) {
        print("changePhoto")
        print(sender.tag)

        selectedSeqNo = sender.tag

        photoPrtocol?.showPhoto(seq: sender.tag)
    }


    
    // 撮影ボタンクリック
   // func *@objc /
    @objc func ClickCamera(_ sender: AnyObject) {
        if AppCommon.checkCameraAuthStatus(controller: self) {
            performSegue(withIdentifier: "SegueModalBLogCamera",sender: self)
        }
    }
}
