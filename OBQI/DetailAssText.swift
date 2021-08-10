//
//  DetailAssText.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/08.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit
import Darwin

class DetailAssText: UIViewController, UITextFieldDelegate {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var labelAssName: UILabel!
    @IBOutlet weak var textInput: UITextField!
    @IBOutlet weak var labelError: UILabel!
    // 初期値
    var firstValue : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textInput.becomeFirstResponder()
        
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
        }
        
        textInput.delegate = self
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
        print("textFieldDidBeginEditing: \(textField.text ?? "")")
    }
    
    /*
     テキストが編集された際に呼ばれる.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        //println("textField: \(textField.text )")
        //println("string: \(string)")
        //println("location: \(range.location)")
        //println("length: \(range.length)")
        // 入力済みの文字と入力された文字を合わせて取得.
        let txtAfterUpdate:NSString = (self.textInput.text as NSString?)!
        let text = txtAfterUpdate.replacingCharacters(in: range, with: string)
        
        //println("textInput: \(text)")
        if text == "" {
            labelError.text = ""
            return true
        }
        if appDelegate.SelectedMstAssessmentItem!["InputValueID"].asString == AppConst.InputValueID.NUM.rawValue
        {
            let val = text.toDouble()
            print("val: \(val)")
            if val == nil {
                labelError.text = "半角数値で入力してください。"
                return true
            } else {
                labelError.text = ""
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
            var choice = textInput.text
            
            if labelError.text != ""
            {
                AppCommon.alertMessage(controller: self, title: "エラー", message: "値を保存できませんでした")
                return
            }
            // 数値で、最後がピリオドの場合は削除する
            if appDelegate.SelectedMstAssessmentItem!["InputValueID"].asString == AppConst.InputValueID.NUM.rawValue
            {
                if choice!.endsWith(".") {
                    choice = choice!.replacingOccurrences(of: ".", with: "", options: [], range: nil)
                }
            }
            
            
            if choice != firstValue {
                let array : [AnyObject] = [choice! as AnyObject]
                let assID = appDelegate.SelectedAssAssID!
                let mst = appDelegate.SelectedMstAssessmentItem!
                
                let res = assCommon.regAss(array, assessmentID: assID, selectedAss: mst, isSync: true)
                if !AppCommon.isNilOrEmpty(res.errCode) {
                    AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
                } else {
                    // 変更されているのでフラグを更新する
                    appDelegate.ChangeInputAssFlagForList = true
                }
            }
        } else {
            if !AppCommon.isNilOrEmpty(firstValue) {
                let assID = appDelegate.SelectedAssAssID!
                let mst = appDelegate.SelectedMstAssessmentItem!
                
                let res = assCommon.delAss(assID, selectedAss: mst, isSync: true)
                if !AppCommon.isNilOrEmpty(res.errCode) {
                    AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
                } else {
                    // 変更されているのでフラグを更新する
                    appDelegate.ChangeInputAssFlagForList = true
                }
            }
        }

        if appDelegate.ChangeInputAssFlagForList! {
            // Post Notification（送信）
            let center = NotificationCenter.default
            center.post(name: NSNotification.Name(rawValue: "requiredAssSubList"), object: nil)
        }

        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func tapScreen(_ sender: AnyObject) {
        self.view.endEditing(true);
    }
    
}
