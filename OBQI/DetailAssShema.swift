//
//  DetailAssShema.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/24.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailAssShema: UIViewController, UINavigationControllerDelegate {
    // 表示するIMGビュー
    //var myImageView: UIImageView? = nil
    let pi: CGFloat = 3.1415926535
    
    var myImageView: UIImageView!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    // 対象のアセスメントアイテム
    var currentMstAssessmentList : [JSON] = []
    // 対象のイメージパーツ
    var imagePartsList:[JSON] = []
    // 現在表示されているシェーマ番号(0はメイン)
    var currentImgShemaNo : Int! = 0
    // 削除するためにコントローラを保存する
    var uiButtons : [UIButton] = []
    // シェーマがあるか
    var noSchema = false
    
    // ボタンが表示されているか
    var existsButtonUp = false
    var existsButtonDown = false
    var existsButtonLeft = false
    var existsButtonRight = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    // 初回ロードされた時
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        self.navigationController?.delegate = self
        
        // この画面のアセスメント(imgPartsNoが入っている)だけ取り出す
        currentMstAssessmentList = []
        let assMenuGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
        for i in 0..<appDelegate.MstAssessmentList!.length {
            let mst = appDelegate.MstAssessmentList![i]
            let mstMenuGroupID = mst["AssMenuGroupID"].asInt!
            let mstMenuSubGroupID = mst["AssMenuSubGroupID"].asInt!
            let imgPartsNo : Int? = mst["ImgPartsNo"].asInt
            if imgPartsNo == nil {
                continue
            }
            if mstMenuGroupID == assMenuGroupID && mstMenuSubGroupID == assMenuSubGroupID {
                currentMstAssessmentList.append(mst)
            }
        }
        print("対象のアセスメント数は　\(currentMstAssessmentList.count)")
        // 入力さている値を取得する
        let assCommon = AssCommon()
        appDelegate.InputAssList = assCommon.getInputAssessmentList()
        
        // シェーマが無い場合は次の画面に飛ばす
        let schemaKb = appDelegate.SelectedMstAssessmentSubGroup!["SchemaKB"].asString
        
        // シェーマが無い場合は次の画面に飛ばす
        if schemaKb! == AppConst.SchemaKB.NO_SCHEMA.rawValue {
            performSegue(withIdentifier: "SegueAssInputList",sender: self)
            noSchema = true
            return
        } else {// シェーマがあるばあいはシェーマを設定する
            setShcema()
        }
        // スワイプ認識.
        let mySwipeUp = UISwipeGestureRecognizer(target: self, action: #selector(DetailAssShema.swipeUp(_:)))
        let mySwipeDown = UISwipeGestureRecognizer(target: self, action: #selector(DetailAssShema.swipeDown(_:)))
        let mySwipeRight = UISwipeGestureRecognizer(target: self, action: #selector(DetailAssShema.swipeRight(_:)))
        let mySwipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(DetailAssShema.swipeLeft(_:)))
        
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
        
        if noSchema {
            return
        }
        if appDelegate.ChangeInputAssFlagForShcema == true {
            clearButtons()
            setShcema()
        }
    }
    
    @IBAction func update(_ sender: Any) {
        let appCommon = AppCommon()
        appCommon.updateImgMaster()
        clearButtons()
        setShcema()
    }
    
    func setShcema() {
        let assCommon = AssCommon()
        let common = AppCommon()
        // Viewの高さと幅を取得する.
        let displayHeight: CGFloat = self.view.frame.height
        // Status Barの高さを取得をする.
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.navigationController?.navigationBar.frame.size.height
        let navBarWidth = self.navigationController?.navigationBar.frame.size.width
        
        
        let barHeight = statusBarHeight + navBarHeight!
        // UIImageView
        myImageView = UIImageView(frame: CGRect(x: 0, y: barHeight, width: navBarWidth!, height: displayHeight - barHeight))
        // mode
        myImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        // 入力されているアセスメントを取得する
        // ViewDidloadで取得しているので、変更している場合のみ取得する
        if appDelegate.ChangeInputAssFlagForShcema == true {
            appDelegate.InputAssList = assCommon.getInputAssessmentList()
            appDelegate.ChangeInputAssFlagForShcema = false // フラグを戻す
        }
        let inputAssList = appDelegate.InputAssList
        
        // 表示する画像を設定する.
        var imagePath : String! = ""
        switch currentImgShemaNo
        {
        case 1:
            imagePath = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaPath1"].asString!
            break
        case 2:
            imagePath = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaPath2"].asString!
            break
        case 3:
            imagePath = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaPath3"].asString!
            break
        case 4:
            imagePath = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaPath4"].asString!
            break
        default:
            imagePath = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaMainPath"].asString!
        }
        //println(imagePath)
        var image = common.getImage(imagePath)
        
        // 画像をUIImageViewに設定する.
        myImageView!.image = image
        self.view.addSubview(myImageView)
        
        // 対象サブメニューに一致するデータのみ取得
        let assMenuGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
        
        imagePartsList = []
        for i in 0 ..< appDelegate.MstAssImagePartsList!.length {
            let imgPartsID = appDelegate.MstAssImagePartsList![i]["ImgPartsID"].asInt!
            let imgPartsSubID = appDelegate.MstAssImagePartsList![i]["ImgPartsSubID"].asInt!
            let imgShemaNo = appDelegate.MstAssImagePartsList![i]["ImgSchemaNo"].asInt
            
            if imgPartsID == assMenuGroupID && imgPartsSubID == assMenuSubGroupID && imgShemaNo == currentImgShemaNo {
                imagePartsList.append(appDelegate.MstAssImagePartsList![i])
            }
        }
        
        // ボタン配置
        for i in 0 ..< imagePartsList.count {
            let ob = imagePartsList[i]
            
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
            button.layer.position = CGPoint(x: CGFloat(x!), y: CGFloat(y!) + barHeight)
            
            // 画像(未選択時)
            imagePath = ob["ImgPartsSctPath2"].asString!
            image = common.getImage(imagePath)
            button.setBackgroundImage(image, for: UIControl.State())
            // 画像(選択時)
            imagePath = ob["ImgPartsSctPath1"].asString!
            image = common.getImage(imagePath)
            button.setBackgroundImage(image, for: UIControl.State.selected)
            // 回転
            let angle = ob["ImgPartsLocationAngle"].asDouble
            UIView.animate(withDuration: 0, animations: {
                button.transform = CGAffineTransform.identity.rotated(by: (CGFloat(angle!)*self.pi)/180)
                }, completion:nil)
            // タグにインデックスを保存する
            button.tag = i
            // ボタンの状態を決める
            let selected : Bool! = getImagePartsInputAssNum(imgPartsNo, inputAssList: inputAssList)
            
            button.isSelected = selected
            
            //ボタンをタップした時に実行するメソッドを指定
            button.addTarget(self, action: #selector(DetailAssShema.clickShema(_:)), for:.touchUpInside)
            
            //viewにボタンを追加する
            self.view.addSubview(button)
            uiButtons.append(button)
        }
        let imgSchemaPath1 = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaPath1"].asString
        let imgSchemaPath2 = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaPath2"].asString
        let imgSchemaPath3 = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaPath3"].asString
        let imgSchemaPath4 = appDelegate.SelectedMstAssessmentSubGroup!["ImgSchemaPath4"].asString
        
        // 上下左右ボタン表示
        existsButtonUp = false
        existsButtonDown = false
        existsButtonRight = false
        existsButtonLeft = false
        
        if currentImgShemaNo == 3 || (currentImgShemaNo == 0 && !AppCommon.isNilOrEmpty(imgSchemaPath1)) {
            // 上
            existsButtonUp = true
            let imageUp = UIImage(named: "move_up.png")
            let buttonUp : UIButton = UIButton()
            let sizeX : CGFloat = 100
            let sizeY : CGFloat = 40
            buttonUp.frame = CGRect(x: 0,y: 0,width: sizeX,height: sizeY)
            buttonUp.layer.position = CGPoint(x: navBarWidth!/2, y:barHeight + sizeY/2)
            buttonUp.setBackgroundImage(imageUp, for: UIControl.State())
            buttonUp.alpha = 0.5 // 透過
            buttonUp.addTarget(self, action: #selector(DetailAssShema.clickUp(_:)), for:.touchUpInside)
            self.view.addSubview(buttonUp)
            uiButtons.append(buttonUp)
        }
        if currentImgShemaNo == 1 || (currentImgShemaNo == 0 && !AppCommon.isNilOrEmpty(imgSchemaPath3)) {
            // 下
            existsButtonDown = true
            let imageDown = UIImage(named: "move_down.png")
            let buttonDown : UIButton = UIButton()
            let sizeX : CGFloat = 100
            let sizeY : CGFloat = 40
            buttonDown.frame = CGRect(x: 0,y: 0,width: sizeX,height: sizeY)
            buttonDown.layer.position = CGPoint(x: navBarWidth!/2, y:displayHeight - sizeY/2)
            buttonDown.setBackgroundImage(imageDown, for: UIControl.State())
            buttonDown.alpha = 0.5 // 透過
            buttonDown.addTarget(self, action: #selector(DetailAssShema.clickDown(_:)), for:.touchUpInside)
            self.view.addSubview(buttonDown)
            uiButtons.append(buttonDown)
        }
        if currentImgShemaNo == 4 || (currentImgShemaNo == 0 && !AppCommon.isNilOrEmpty(imgSchemaPath2)) {
            // 右
            existsButtonRight = true
            let imageRight = UIImage(named: "move_right.png")
            let buttonRight : UIButton = UIButton()
            let sizeX : CGFloat = 40
            let sizeY : CGFloat = 100
            buttonRight.frame = CGRect(x: 0,y: 0,width: sizeX,height: sizeY)
            buttonRight.layer.position = CGPoint(x: navBarWidth! - sizeX/2, y:displayHeight/2)
            buttonRight.setBackgroundImage(imageRight, for: UIControl.State())
            buttonRight.alpha = 0.5 // 透過
            buttonRight.addTarget(self, action: #selector(DetailAssShema.clickRight(_:)), for:.touchUpInside)
            self.view.addSubview(buttonRight)
            uiButtons.append(buttonRight)
        }
        if currentImgShemaNo == 2 || (currentImgShemaNo == 0 && !AppCommon.isNilOrEmpty(imgSchemaPath4)) {
            // 左
            existsButtonLeft = true
            let imageLeft = UIImage(named: "move_left.png")
            let buttonLeft : UIButton = UIButton()
            let sizeX : CGFloat = 40
            let sizeY : CGFloat = 100
            buttonLeft.frame = CGRect(x: 0,y: 0,width: sizeX,height: sizeY)
            buttonLeft.layer.position = CGPoint(x: 0 + sizeX/2, y:displayHeight/2)
            buttonLeft.setBackgroundImage(imageLeft, for: UIControl.State())
            buttonLeft.alpha = 0.5 // 透過
            buttonLeft.addTarget(self, action: #selector(DetailAssShema.clickLeft(_:)), for:.touchUpInside)
            self.view.addSubview(buttonLeft)
            uiButtons.append(buttonLeft)
        }
    }
    // 対象のイメージパーツで入力アセスメントがあるか？（入力されているか？）
    func getImagePartsInputAssNum(_ imgPartsNo : Int!, inputAssList : JSON?) -> Bool! {
        if (inputAssList == nil) {
            return false
        }
        
        for j in 0 ..< currentMstAssessmentList.count {
            let mst = currentMstAssessmentList[j]
            // AssMenuGroupID,AssMenuSubGroupIDの２つはすでに一致しているリストであるためImgPartsNoのみの比較
            let mstImgPartsNo = mst["ImgPartsNo"].asInt
            // PartsNoが一致するデータのみ比較
            if (mstImgPartsNo == imgPartsNo) {
                let mstAssMenuGroupID = mst["AssMenuGroupID"].asInt!
                let mstAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt!
                let mstAssItemID = mst["AssItemID"].asInt!
                
                for i in 0 ..< inputAssList!.length {
                    let ob = inputAssList![i]
                    let inputAssMenuGroupID = ob["AssMenuGroupID"].asInt!
                    let inputAssMenuSubGroupID = ob["AssMenuSubGroupID"].asInt!
                    let inputAssItemID = ob["AssItemID"].asInt!
                    
                    if mstAssMenuGroupID == inputAssMenuGroupID
                        && mstAssMenuSubGroupID == inputAssMenuSubGroupID
                        && mstAssItemID == inputAssItemID {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    // シェーマのボタンクリックイベント
    @objc func clickShema(_ sender: UIButton) {
        print("tapped")
        let asscommon = AssCommon()
       
        
        // カメラが無い場合は次の画面に飛ばす
        let schemaKb = appDelegate.SelectedMstAssessmentSubGroup!["SchemaKB"].asString!
        print(schemaKb)
        let assMenuGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuGroupID"].asInt!
        let assMenuSubGroupID = appDelegate.SelectedMstAssessmentSubGroup!["AssMenuSubGroupID"].asInt!
        let imgPartsNo = imagePartsList[sender.tag]["ImgPartsNo"].asInt!
        // imgPartsNo保存
        appDelegate.SelectedAssImagePartsNo = imgPartsNo
        
        switch (schemaKb) {
        case AppConst.SchemaKB.SINGLE.rawValue, AppConst.SchemaKB.MULTI.rawValue: // 択一 or 複数
            var existsCamera = false
            for i in 0..<appDelegate.MstAssessmentList!.length {
                let mst = appDelegate.MstAssessmentList![i]
                let mstMenuGroupID = mst["AssMenuGroupID"].asInt!
                let mstMenuSubGroupID = mst["AssMenuSubGroupID"].asInt!
                let imgPartsNo : Int? = mst["ImgPartsNo"].asInt
                let assInputKB = mst["AssInputKB"].asString!
                
                if mstMenuGroupID == assMenuGroupID && mstMenuSubGroupID == assMenuSubGroupID && AppConst.InputKB.PHOTO.rawValue == assInputKB && imgPartsNo == appDelegate.SelectedAssImagePartsNo {
                    appDelegate.SelectedMstAssessmentItem = mst
                    existsCamera = true
                    break
                }
            }
            if existsCamera { // カメラあり
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            } else {
                performSegue(withIdentifier: "SegueAssInputList",sender: self)
            }
            break
        case AppConst.SchemaKB.ONLY_SCHEMA_SINGLE.rawValue, AppConst.SchemaKB.ONLY_SCHEMA_MULTI.rawValue: // シェーマのみ択一・複数選択
            print("ONLY_SCHEMA_SINGLE or ONLY_SCHEMA_MULTI")
            
            if !sender.isSelected { // 選択時
                for i in 0..<appDelegate.MstAssessmentList!.length {
                    let tmpAssMenuGroupID = appDelegate.MstAssessmentList?[i]["AssMenuGroupID"].asInt
                    let tmpAssMenuSubGroupID = appDelegate.MstAssessmentList?[i]["AssMenuSubGroupID"].asInt
                    let tmpImgPartsNo = appDelegate.MstAssessmentList?[i]["ImgPartsNo"].asInt
                    
                    if tmpAssMenuGroupID == assMenuGroupID
                        && tmpAssMenuSubGroupID == assMenuSubGroupID
                        && tmpImgPartsNo == imgPartsNo {
                        let choices = appDelegate.MstAssessmentList?[i]["AssChoices"].asString
                        if AppCommon.isNilOrEmpty(choices) {
                            continue
                        }
                        let choiceStrArray = choices?.components(separatedBy: ",")
                        let firstChoice = choiceStrArray?[0]
                        var choiceArray : [AnyObject] = []
                        choiceArray.append(firstChoice! as AnyObject)
                        let res = asscommon.regAss(choiceArray, assessmentID: appDelegate.SelectedAssAssID!, selectedAss: appDelegate.MstAssessmentList?[i], isSync: false)
                        if !AppCommon.isNilOrEmpty(res.errCode) {
                            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                        }
                        break
                    }
                }
            } else { // 選択解除
                for i in 0..<appDelegate.MstAssessmentList!.length {
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
                            let res = asscommon.delAss(appDelegate.SelectedAssAssID!, selectedAss: appDelegate.MstAssessmentList?[i], isSync: false)
                            if !AppCommon.isNilOrEmpty(res.errCode) {
                                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                            }
                        }
                    }
                }
            }
            // 選択状態を切り替え
            sender.isSelected = !sender.isSelected
            appDelegate.ChangeInputAssFlagForShcema = true
            break
        case AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_SINGLE.rawValue: // シェーマのみカメラあり、択一
            if !sender.isSelected { // 選択時
                var existsCamera = false
                //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
                for i in 0..<appDelegate.MstAssessmentList!.length {
                    let mst = appDelegate.MstAssessmentList![i]
                    let tmpAssMenuGroupID = mst["AssMenuGroupID"].asInt
                    let tmpAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt
                    let tmpImgPartsNo = mst["ImgPartsNo"].asInt
                    let tmpAssInputKB = mst["AssInputKB"].asString!
                    // カメラ以外は最初の選択肢を登録する
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
                            let res = asscommon.regAss(choiceArray, assessmentID: appDelegate.SelectedAssAssID!, selectedAss: mst, isSync: false)
                            if !AppCommon.isNilOrEmpty(res.errCode) {
                                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                            }
                        } else if !existsCamera { // 写真
                            appDelegate.SelectedMstAssessmentItem = mst
                            existsCamera = true
                        }
                    }
                }
                // 選択状態を切り替え
                sender.isSelected = !sender.isSelected
                if existsCamera {
                    performSegue(withIdentifier: "SegueAssPhoto",sender: self)
                }
            } else { // 選択解除
                //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
                for i in 0..<appDelegate.MstAssessmentList!.length {
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
                            let res = asscommon.delAss(appDelegate.SelectedAssAssID!, selectedAss: appDelegate.MstAssessmentList?[i], isSync: false)
                            if !AppCommon.isNilOrEmpty(res.errCode) {
                                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                            }
                        }
                    }
                }
                // 選択状態を切り替え
                sender.isSelected = !sender.isSelected
            }
            appDelegate.ChangeInputAssFlagForShcema = true
            break
        case AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_MULTI.rawValue: // シェーマのみカメラあり、複数
            if !sender.isSelected { // 選択時
                var existsCamera = false
                //for var i = 0; i < appDelegate.MstAssessmentList?.length; i += 1 {
                for i in 0..<appDelegate.MstAssessmentList!.length {
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
                            let res = asscommon.regAss(choiceArray, assessmentID: appDelegate.SelectedAssAssID!, selectedAss: mst, isSync: false)
                            if !AppCommon.isNilOrEmpty(res.errCode) {
                                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                            }
                        } else if !existsCamera {
                            appDelegate.SelectedMstAssessmentItem = mst
                            existsCamera = true
                        }
                    }
                }
                // 選択状態を切り替え
                sender.isSelected = !sender.isSelected
                if existsCamera {
                    performSegue(withIdentifier: "SegueAssPhoto",sender: self)
                }
            } else { // 選択解除
                for i in 0..<appDelegate.MstAssessmentList!.length {
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
                            let res = asscommon.delAss(appDelegate.SelectedAssAssID!, selectedAss: appDelegate.MstAssessmentList?[i], isSync: false)
                            if !AppCommon.isNilOrEmpty(res.errCode) {
                                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                            }
                        }
                    }
                }
                // 選択状態を切り替え
                sender.isSelected = !sender.isSelected
            }
            appDelegate.ChangeInputAssFlagForShcema = true
            break
        case AppConst.SchemaKB.SINGLE_REQUIRE_PHOTO.rawValue: // シェーマあり択一（写真必須）
            if !sender.isSelected { // 選択時
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            } else { // 選択解除
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            }
            break
        case AppConst.SchemaKB.MULTI_REQUIRE_PHOTO.rawValue: // シェーマあり複数選択（写真必須）
            if !sender.isSelected { // 選択時
                for i in 0..<appDelegate.MstAssessmentList!.length {
                    let mst = appDelegate.MstAssessmentList![i]
                    let tmpAssMenuGroupID = mst["AssMenuGroupID"].asInt
                    let tmpAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt
                    let tmpImgPartsNo = mst["ImgPartsNo"].asInt
                    let tmpAssInputKB = mst["AssInputKB"].asString!
                    // カメラ以外は最初の選択肢を登録する
                    if tmpAssMenuGroupID == assMenuGroupID
                        && tmpAssMenuSubGroupID == assMenuSubGroupID
                        && tmpImgPartsNo == imgPartsNo {
                        if tmpAssInputKB == AppConst.InputKB.PHOTO.rawValue {
                            appDelegate.SelectedMstAssessmentItem = mst
                            break
                        }
                    }
                }
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            } else { // 選択解除
                for i in 0..<appDelegate.MstAssessmentList!.length {
                    let mst = appDelegate.MstAssessmentList![i]
                    let tmpAssMenuGroupID = mst["AssMenuGroupID"].asInt
                    let tmpAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt
                    let tmpImgPartsNo = mst["ImgPartsNo"].asInt
                    let tmpAssInputKB = mst["AssInputKB"].asString!
                    // カメラ以外は最初の選択肢を登録する
                    if tmpAssMenuGroupID == assMenuGroupID
                        && tmpAssMenuSubGroupID == assMenuSubGroupID
                        && tmpImgPartsNo == imgPartsNo {
                        if tmpAssInputKB == AppConst.InputKB.PHOTO.rawValue {
                            appDelegate.SelectedMstAssessmentItem = mst
                            break
                        }
                    }
                }
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            }
            break
        case AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_SINGLE_REQUIRE_PHOTO.rawValue: // シェーマのみ写真択一選択（写真必須）
            if !sender.isSelected { // 選択時
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            } else { // 選択解除
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            }
            break
        case AppConst.SchemaKB.ONLY_SCHEMA_PHOTO_MULTI_REQUIRE_PHOTO.rawValue: // シェーマのみ写真複数選択（写真必須）
            if !sender.isSelected { // 選択時
                for i in 0..<appDelegate.MstAssessmentList!.length {
                    let mst = appDelegate.MstAssessmentList![i]
                    let tmpAssMenuGroupID = mst["AssMenuGroupID"].asInt
                    let tmpAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt
                    let tmpImgPartsNo = mst["ImgPartsNo"].asInt
                    let tmpAssInputKB = mst["AssInputKB"].asString!
                    // カメラ以外は最初の選択肢を登録する
                    if tmpAssMenuGroupID == assMenuGroupID
                        && tmpAssMenuSubGroupID == assMenuSubGroupID
                        && tmpImgPartsNo == imgPartsNo {
                        if tmpAssInputKB == AppConst.InputKB.PHOTO.rawValue {
                            appDelegate.SelectedMstAssessmentItem = mst
                            break
                        }
                    }
                }
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            } else { // 選択解除
                for i in 0..<appDelegate.MstAssessmentList!.length {
                    let mst = appDelegate.MstAssessmentList![i]
                    let tmpAssMenuGroupID = mst["AssMenuGroupID"].asInt
                    let tmpAssMenuSubGroupID = mst["AssMenuSubGroupID"].asInt
                    let tmpImgPartsNo = mst["ImgPartsNo"].asInt
                    let tmpAssInputKB = mst["AssInputKB"].asString!
                    // カメラ以外は最初の選択肢を登録する
                    if tmpAssMenuGroupID == assMenuGroupID
                        && tmpAssMenuSubGroupID == assMenuSubGroupID
                        && tmpImgPartsNo == imgPartsNo {
                        if tmpAssInputKB == AppConst.InputKB.PHOTO.rawValue {
                            appDelegate.SelectedMstAssessmentItem = mst
                            break
                        }
                    }
                }
                performSegue(withIdentifier: "SegueAssPhoto",sender: self)
            }
            break
        default:
            break
        }
        
    }
    
    
    
    // 配置したボタンを削除する
    func clearButtons() {
        myImageView.removeFromSuperview()
        
        for i in 0 ..< uiButtons.count {
            uiButtons[i].removeFromSuperview()
        }
        uiButtons = []
    }
    @objc func clickUp(_ sender: UIButton) {
        print("clickUp")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonUp {
            return
        }
        if (currentImgShemaNo == 3) {
            clearButtons()
            currentImgShemaNo = 0
            setShcema()
        } else if (currentImgShemaNo == 0) {
            clearButtons()
            currentImgShemaNo = 1
            setShcema()
        }
    }
    @objc func clickDown(_ sender: UIButton) {
        print("clickDown")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonDown {
            return
        }
        if (currentImgShemaNo == 1) {
            clearButtons()
            currentImgShemaNo = 0
            setShcema()
        } else if (currentImgShemaNo == 0) {
            clearButtons()
            currentImgShemaNo = 3
            setShcema()
        }
    }
    @objc func clickRight(_ sender: UIButton) {
        print("clickRight")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonRight {
            return
        }
        if (currentImgShemaNo == 4) {
            clearButtons()
            currentImgShemaNo = 0
            setShcema()
        } else if (currentImgShemaNo == 0) {
            clearButtons()
            currentImgShemaNo = 2
            setShcema()
        }
    }
    @objc func clickLeft(_ sender: UIButton) {
        print("clickLeft")
        // ボタンが表示されていない場合は処理を行わない
        if !existsButtonLeft {
            return
        }
        if (currentImgShemaNo == 2) {
            clearButtons()
            currentImgShemaNo = 0
            setShcema()
        } else if (currentImgShemaNo == 0) {
            clearButtons()
            currentImgShemaNo = 4
            setShcema()
        }
    }
    /*
     スワイプイベント
     */
    @objc func swipeUp(_ sender: UISwipeGestureRecognizer){
        print("swipeUp")
        clickDown(UIButton())
    }
    @objc func swipeDown(_ sender: UISwipeGestureRecognizer){
        print("swipeDown")
        clickUp(UIButton())
    }
    @objc func swipeRight(_ sender: UISwipeGestureRecognizer){
        print("swipeRight")
        clickLeft(UIButton())
    }
    @objc func swipeLeft(_ sender: UISwipeGestureRecognizer){
        print("swipeLeft")
        clickRight(UIButton())
    }
    
}
