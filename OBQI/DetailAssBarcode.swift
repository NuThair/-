//
//  DetailAssBarcode.swift
//  SkinFloraME
//
//  Created by ToyamaYoshimasa on 2015/04/21.
//  Copyright (c) 2015年 OrangeAct. All rights reserved.
//

import UIKit
import AVFoundation

class DetailAssBarcode: UIViewController ,UITextFieldDelegate{
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var labelAssName: UILabel!
    @IBOutlet weak var labelError: UILabel!
    // 初期値
    var firstValue : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let assCommon = AssCommon()
        // 選択肢を取得する
        let mst = appDelegate.SelectedMstAssessmentItem!
        
        textInput.delegate = self
        // キーボードタイプを切り替える
        if mst["InputValueID"].asString == AppConst.InputValueID.NUM.rawValue {
            textInput.keyboardType = UIKeyboardType.numberPad
        }
        
        // AssNameを設定する
        labelAssName.text = mst["AssName"].asString
        let unit = mst["AssUnit"].asString
        if !AppCommon.isNilOrEmpty(unit) {
            labelAssName.text = "\(labelAssName.text!)(単位：\(unit!))"
        }
        // 登録されている値を取得する
        
        let inputValue = assCommon.getAssInput(appDelegate.InputAssList, mstAssessment: appDelegate.SelectedMstAssessmentItem)
        if inputValue.count > 0 {
            firstValue = inputValue[0]["AssChoicesAsr"].asString
            textInput.text = firstValue
            print(firstValue!)
        }
        
        textInput.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        if appDelegate.CaptureBarcode != nil {
            textInput.text = appDelegate.CaptureBarcode
            appDelegate.CaptureBarcode = nil
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func clickReadBarcode(_ sender: AnyObject) {
        //let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized,.notDetermined:
            appDelegate.CaptureBarcode = nil
            performSegue(withIdentifier: "SegueBarcode",sender: self)
        case .denied:
            AppCommon.alertMessage(controller: self, title: "エラー", message: "カメラへのアクセスが許可されていません。")
        case .restricted:
            break
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    /*
    UITextFieldが編集開始された直後に呼ばれる.
    */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing: \(textField.text)")
    }
    
    /*
    テキストが編集された際に呼ばれる.
    */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("textField: \(textField.text )")
        print("string: \(string)")
        print("location: \(range.location)")
        print("length: \(range.length)")
        
        if string == "" {
            return true
        }
        if appDelegate.SelectedMstAssessmentItem!["InputValueID"].asString == AppConst.InputValueID.NUM.rawValue
        {
            let val = Int(string)
            if val == nil {
                labelError.text = "半角数値で入力してください。"
                return true
            }
        }
        return true
    }
    /*
    UITextFieldが編集終了する直前に呼ばれる.
    */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing: \(textField.text)")
        return true
    }

    @IBAction func clickDelete(_ sender: AnyObject) {
        textInput.text = ""
    }
    /*
    戻る
    値が変更されていたら更新する
    */
    override func viewWillDisappear(_ animated: Bool) {
        let assCommon = AssCommon()
        // 入力されている文字を取得する
        if !AppCommon.isNilOrEmpty(textInput.text) {
            //let cell = myTableView?.cellForRowAtIndexPath(indexPath!)
            let choice = textInput.text!
            
            if labelError.text != ""
            {
                AppCommon.alertMessage(controller: self, title: "エラー", message: "値を保存できませんでした。")
                return
            }
            
            if choice != firstValue {
                if  let val = isAlreadyInput(choice) {
                    AppCommon.alertMessage(controller: self, title: "エラー", message: "この番号は[ \(val) ]のユーザで既に使用されておりますので、保存できませんでした。")
                    return
                }
                
                let array : [AnyObject] = [choice as AnyObject]
                let assID = appDelegate.SelectedAssAssID!
                let mst = appDelegate.SelectedMstAssessmentItem!
                
                
                _ = assCommon.regAss(array, assessmentID: assID, selectedAss: mst, isSync: true)
                // 変更されているのでフラグを更新する
                appDelegate.ChangeInputAssFlagForList = true
            }
        } else {
            if !AppCommon.isNilOrEmpty(firstValue) {
                let assID = appDelegate.SelectedAssAssID!
                let mst = appDelegate.SelectedMstAssessmentItem!
                
                _ = assCommon.delAss(assID, selectedAss: mst, isSync: true)
                // 変更されているのでフラグを更新する
                appDelegate.ChangeInputAssFlagForList = true
            }
        }

        if appDelegate.ChangeInputAssFlagForList! {
            // Post Notification（送信）
            let center = NotificationCenter.default
            center.post(name: NSNotification.Name(rawValue: "requiredAssSubList"), object: nil)
        }

        super.viewWillDisappear(animated)
    }
    // 入力した値が既に使用されているかチェックする
    // 誰も使用していなかったらnil
    func isAlreadyInput(_ choice : String!) -> Int? {
        let mst = appDelegate.SelectedMstAssessmentItem!
        let mstMenuGroupID = mst["AssMenuGroupID"].asInt!
        let mstMenuSubGroupID = mst["AssMenuSubGroupID"].asInt!
        let mstItemID = mst["AssItemID"].asInt!
        
        let url = "\(AppConst.URLPrefix)assessment/GetSameAnswer/\(mstMenuGroupID)/\(mstMenuSubGroupID)/\(mstItemID)/\(choice!)"
        let res = appCommon.getSynchronous(url)
        if let value = Int(res.result!) {
            if value < 0 {
                return nil
            } else {
                return value
            }
        } else {
            return nil
        }
    }

    
    @IBAction func tapScreen(_ sender: AnyObject) {
        self.view.endEditing(true);
    }

}
