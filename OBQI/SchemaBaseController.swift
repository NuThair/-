//
//  SchemaBaseController.swift
//  OBQI
//
//  Created by t.o on 2017/03/16.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class SchemaBaseController: UIViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var schemaProtocol:SchemaProtocol?

    var myImageView: UIImageView!

    let pi: CGFloat = 3.1415926535

    // 対象のイメージパーツ
    var imagePartsList:[JSON] = []
    // 現在表示されているシェーマ番号(0はメイン)
    var currentDirection = AppConst.ArrowDirection.MAIN
    var currentPosition = (x: 0, y: 0)
    // 削除するためにコントローラを保存する
    var uiButtons : [UIButton] = []

    // ボタンが表示されているか
    var existsButtonUp = false
    var existsButtonDown = false
    var existsButtonLeft = false
    var existsButtonRight = false

    // 子クラスで設定
    // 選択したデータ
    var selectedData:JSON?
    var selectedGroupID:Int?
    var selectedSubGroupID:Int?

    // 描画領域
    var plotArea = CGRect(x: 0, y: 0, width: 0, height: 0)

    // 初回ロードされた時
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")

        // 子クラスで実装がおこなわれるメソッド群
        schemaProtocol = self as? SchemaProtocol

        // UIImageView
        myImageView = UIImageView(frame: plotArea)
        // mode
        myImageView.contentMode = UIView.ContentMode.scaleAspectFit

        // スワイプ認識.
        let mySwipeUp = UISwipeGestureRecognizer(target: self, action:#selector(SchemaBaseController.swipeUp(_:)))
        let mySwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(SchemaBaseController.swipeDown(_:)))
        let mySwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(SchemaBaseController.swipeRight(_:)))
        let mySwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(SchemaBaseController.swipeLeft(_:)))

        mySwipeUp.direction = UISwipeGestureRecognizer.Direction.up
        mySwipeDown.direction = UISwipeGestureRecognizer.Direction.down
        mySwipeRight.direction = UISwipeGestureRecognizer.Direction.right
        mySwipeLeft.direction = UISwipeGestureRecognizer.Direction.left

        self.view.addGestureRecognizer(mySwipeUp)
        self.view.addGestureRecognizer(mySwipeDown)
        self.view.addGestureRecognizer(mySwipeRight)
        self.view.addGestureRecognizer(mySwipeLeft)

    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // 初期表示
        setShcema()
    }

    // シェーマ画像の作成
    func setShcema() {
        // 選択中の方向から表示する画像を設定する.
        var imagePath = ""
        switch currentDirection
        {
        case .MAIN:
            imagePath = selectedData!["ImgSchemaMainPath"].asString!
            break

        case .UP:
            imagePath = selectedData!["ImgSchemaPath1"].asString!
            break

        case .DOWN:
            imagePath = selectedData!["ImgSchemaPath3"].asString!
            break

        case .RIGHT:
            imagePath = selectedData!["ImgSchemaPath2"].asString!
            break

        case .LEFT:
            imagePath = selectedData!["ImgSchemaPath4"].asString!
            break
        }
        var image = appCommon.getImage(imagePath)

        // 画像をUIImageViewに設定する.
        myImageView!.image = image

        self.view.addSubview(myImageView)

        imagePartsList = (appDelegate.MstAssImagePartsList?
            .filter{
                $0.1["ImgPartsID"].asInt! == selectedGroupID!
                    && $0.1["ImgPartsSubID"].asInt! == selectedSubGroupID!
                    && $0.1["ImgSchemaNo"].asInt! == currentDirection.rawValue
            }
            .map{ $0.1 })!

        // ボタン配置
        imagePartsList.enumerated().forEach { (idx, ob) -> Void in
            let button : UIButton = UIButton()
            // ImgPartsNo
            let imgPartsNo = ob["ImgPartsNo"].asInt!

            // 大きさ
            let height = ob["ImgPartsSizeHeight"].asDouble
            let width = ob["ImgPartsSizeWidth"].asDouble
            button.frame = CGRect(x: 0, y: 0, width: CGFloat(width!), height: CGFloat(height!))
            //配置場所
            let x = ob["ImgPartsLocationX"].asDouble
            let y = ob["ImgPartsLocationY"].asDouble
            button.layer.position = CGPoint(x: CGFloat(x!), y: CGFloat(y!) + plotArea.origin.y)

            // 画像(未選択時)
            imagePath = ob["ImgPartsSctPath2"].asString!
            image = appCommon.getImage(imagePath)
            button.setBackgroundImage(image, for: UIControl.State())
            // 画像(選択時)
            imagePath = ob["ImgPartsSctPath1"].asString!
            image = appCommon.getImage(imagePath)
            button.setBackgroundImage(image, for: UIControl.State.selected)
            // 回転
            let angle = ob["ImgPartsLocationAngle"].asDouble
            UIView.animate(withDuration: 0, animations: {
                button.transform = CGAffineTransform.identity.rotated(by: (CGFloat(angle!)*self.pi)/180)
            }, completion:nil)
            // タグにインデックスを保存する
            button.tag = idx
            // ボタンの状態を決める
            button.isSelected = (schemaProtocol?.checkSelected(groupID: selectedGroupID!, subGroupID: selectedSubGroupID!, imgPartsNo: imgPartsNo))!

            //ボタンをタップした時に実行するメソッドを指定
            button.addTarget(self, action: #selector(SchemaBaseController.clickShema(_:)), for:.touchUpInside)

            //viewにボタンを追加する
            self.view.addSubview(button)
            uiButtons.append(button)
        }
        let imgSchemaPath1 = selectedData!["ImgSchemaPath1"].asString
        let imgSchemaPath2 = selectedData!["ImgSchemaPath2"].asString
        let imgSchemaPath3 = selectedData!["ImgSchemaPath3"].asString
        let imgSchemaPath4 = selectedData!["ImgSchemaPath4"].asString

        // 上下左右ボタン表示
        existsButtonUp = false
        existsButtonDown = false
        existsButtonRight = false
        existsButtonLeft = false

        // メイン画像の場合は移動先があれば矢印表示
        // 移動後の画面は戻る方向の矢印表示
        if currentDirection == .DOWN || (currentDirection == .MAIN && !AppCommon.isNilOrEmpty(imgSchemaPath1)) { // 上
            createArrowButton(AppConst.ArrowDirection.UP)
        }
        if currentDirection == .UP || (currentDirection == .MAIN && !AppCommon.isNilOrEmpty(imgSchemaPath3)) { // 下
            createArrowButton(AppConst.ArrowDirection.DOWN)
        }
        if currentDirection == .LEFT || (currentDirection == .MAIN && !AppCommon.isNilOrEmpty(imgSchemaPath2)) { // 右
            createArrowButton(AppConst.ArrowDirection.RIGHT)
        }
        if currentDirection == .RIGHT || (currentDirection == .MAIN && !AppCommon.isNilOrEmpty(imgSchemaPath4)) { // 左
            createArrowButton(AppConst.ArrowDirection.LEFT)
        }
    }

    // シェーマのボタンクリックイベント
    @objc func clickShema(_ sender: UIButton) {
        print("tapped")

        // カメラが無い場合は次の画面に飛ばす
        let schemaKb = selectedData!["SchemaKB"].asString!
        let imgPartsNo = imagePartsList[sender.tag]["ImgPartsNo"].asInt!
        let selectedSchemaData = schemaProtocol?.getSelectedSchemaData(groupID: selectedGroupID!, subGroupID: selectedSubGroupID!, imgPartsNo: imgPartsNo)
        print(schemaKb)

        // 選択状態の判定
        let willSelect = !sender.isSelected

        switch (schemaKb) {
        case AppConst.SchemaKB.SINGLE.rawValue // シェーマあり択一
        , AppConst.SchemaKB.MULTI.rawValue // シェーマあり複数
        , AppConst.SchemaKB.SINGLE_REQUIRE_PHOTO.rawValue // シェーマあり択一（写真必須）
        , AppConst.SchemaKB.MULTI_REQUIRE_PHOTO.rawValue // シェーマあり複数（写真必須）
        , AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_SINGLE_REQUIRE_PHOTO.rawValue // シェーマのみ択一（写真必須）
        , AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_MULTI_REQUIRE_PHOTO.rawValue: // シェーマのみ複数（写真必須）

            // 次の画面へ遷移
            schemaProtocol?.moveNextView(selectedSchemaData: selectedSchemaData)
            break

        case AppConst.SchemaKB.ONLY_SCHEMA_SINGLE.rawValue: // シェーマのみ択一
            // TODO 完了なら変更できない
            // 一旦SubGroupHD単位で削除
            schemaProtocol?.deleteItemAll()

            // 選択済みに変化した時のみ登録処理
            if willSelect {
                // 選択状態全解除
                uiButtons.forEach{
                    $0.isSelected = false
                }

                // 登録
                schemaProtocol?.saveItem(selectedSchemaData: selectedSchemaData)
            }

            // 選択状態を切り替え
            sender.isSelected = willSelect
            break

        case AppConst.SchemaKB.ONLY_SCHEMA_MULTI.rawValue: // シェーマのみ複数
            // TODO 完了なら変更できない

            // 選択状態によって処理分岐
            if willSelect {
                schemaProtocol?.saveItem(selectedSchemaData: selectedSchemaData)
            } else {
                schemaProtocol?.deleteItem(selectedSchemaData: selectedSchemaData)
            }

            // 選択状態を切り替え
            sender.isSelected = willSelect
            break

//        case AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_SINGLE.rawValue: // シェーマのみ択一（写真あり）
//            break
//
//        case AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_MULTI.rawValue: // シェーマのみ複数（写真あり）
//            break

        default: break
        }

    }


    // 移動ボタンの作成
    func createArrowButton(_ direction: AppConst.ArrowDirection) {
        let button : UIButton = UIButton()
        let longSide : CGFloat = 100
        let shortSide : CGFloat = 40
        button.alpha = 0.5 // 透過

        var image:UIImage?
        switch direction {
        case .UP:
            existsButtonUp = true
            image = UIImage(named: "move_up.png")
            button.frame = CGRect(x: 0, y: 0, width: longSide, height: shortSide)
            button.layer.position = CGPoint(x: plotArea.width/2, y: plotArea.origin.y + shortSide/2)
            button.addTarget(self, action: #selector(SchemaBaseController.clickUp(_:)), for:.touchUpInside)

        case .DOWN:
            existsButtonDown = true
            image = UIImage(named: "move_down.png")
            button.frame = CGRect(x: 0, y: 0, width: longSide, height: shortSide)
            button.layer.position = CGPoint(x: plotArea.width/2, y: self.view.frame.height - shortSide/2)
            button.addTarget(self, action: #selector(SchemaBaseController.clickDown(_:)), for:.touchUpInside)

        case .RIGHT:
            existsButtonRight = true
            image = UIImage(named: "move_right.png")
            button.frame = CGRect(x: 0, y: 0, width: shortSide, height: longSide)
            button.layer.position = CGPoint(x: plotArea.width - shortSide/2, y: plotArea.height/2)
            button.addTarget(self, action: #selector(SchemaBaseController.clickRight(_:)), for:.touchUpInside)

        case .LEFT:
            existsButtonLeft = true
            image = UIImage(named: "move_left.png")
            button.frame = CGRect(x: 0, y: 0, width: shortSide, height: longSide)
            button.layer.position = CGPoint(x: shortSide/2, y: plotArea.height/2)
            button.addTarget(self, action: #selector(SchemaBaseController.clickLeft(_:)), for:.touchUpInside)

        default: break
        }

        button.setBackgroundImage(image!, for: UIControl.State())
        self.view.addSubview(button)
        uiButtons.append(button)
    }

    // 配置したボタンを削除する
    func clearButtons() {
        myImageView.removeFromSuperview()

        for i in 0 ..< uiButtons.count {
            uiButtons[i].removeFromSuperview()
        }
        uiButtons = []
    }
    func changeDirection(_ direction: AppConst.ArrowDirection) {
        print("change\(direction)")

        // 移動方向
        switch direction {
        case .UP:
            currentPosition.y += 1
        case .DOWN:
            currentPosition.y -= 1
        case .RIGHT:
            currentPosition.x += 1
        case .LEFT:
            currentPosition.x -= 1
        default: break
        }

        //　表示中の向きを判定
        if currentPosition.y == 0 && currentPosition.x == 0 { // メイン
            currentDirection = .MAIN

        } else if currentPosition.y == 1 { // 上
            currentDirection = .UP

        } else if currentPosition.y == -1 { // 下
            currentDirection = .DOWN

        } else if currentPosition.x == 1 { // 右
            currentDirection = .RIGHT

        } else if currentPosition.x == -1 { // 左
            currentDirection = .LEFT
        }

        clearButtons()
        setShcema()
    }

    /*
     クリックイベント
     */
    @objc func clickUp(_ sender: UIButton) {
        print("clickUp")
        changeDirection(AppConst.ArrowDirection.UP)
    }
    @objc func clickDown(_ sender: UIButton) {
        print("clickDown")
        changeDirection(AppConst.ArrowDirection.DOWN)
    }
    @objc func clickRight(_ sender: UIButton) {
        print("clickRight")
        changeDirection(AppConst.ArrowDirection.RIGHT)
    }
    @objc func clickLeft(_ sender: UIButton) {
        print("clickLeft")
        changeDirection(AppConst.ArrowDirection.LEFT)
    }

    /*
     スワイプイベント
     */
    @objc func swipeUp(_ sender: UISwipeGestureRecognizer){
        print("swipeUp")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonDown {
            return
        }
        changeDirection(AppConst.ArrowDirection.DOWN)
    }
    @objc func swipeDown(_ sender: UISwipeGestureRecognizer){
        print("swipeDown")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonUp {
            return
        }
        changeDirection(AppConst.ArrowDirection.UP)
    }
    @objc func swipeRight(_ sender: UISwipeGestureRecognizer){
        print("swipeRight")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonLeft {
            return
        }
        changeDirection(AppConst.ArrowDirection.LEFT)
    }
    @objc func swipeLeft(_ sender: UISwipeGestureRecognizer){
        print("swipeLeft")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonRight {
            return
        }
        changeDirection(AppConst.ArrowDirection.RIGHT)
    }
    
}
