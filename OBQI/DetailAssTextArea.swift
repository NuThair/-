//
//  DetailAssTextArea.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/09.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit
import Darwin

class DetailAssTextArea: UIViewController  {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var labelAssName: UILabel!
    // 初期値
    var firstValue : String?
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.becomeFirstResponder()
        
        let assCommon = AssCommon()
        // 選択肢を取得する
        let mst = appDelegate.SelectedMstAssessmentItem!
        
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
            textView.text = firstValue
        }
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func clickDelete(_ sender: AnyObject) {
        textView.text = ""
    }
    @IBAction func tapScreen(_ sender: AnyObject) {
        self.view.endEditing(true);
    }
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        let assCommon = AssCommon()
        // 入力されている文字を取得する
        if !AppCommon.isNilOrEmpty(textView.text) {
            //let cell = myTableView?.cellForRowAtIndexPath(indexPath!)
            let choice = textView.text
            
            if choice != firstValue {
                let array : [AnyObject] = [choice as AnyObject]
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
    
}
