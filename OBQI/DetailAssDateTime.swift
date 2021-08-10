//
//  DetailAssDateTime.swift
//  OBQI
//
//  Created by t.o on 2017/04/07.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailAssDateTime: UIViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

    @IBOutlet weak var labelAssName: UILabel!

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var labelInput: UILabel!
    // 初期値
    var firstValue : String?

    override func viewDidLoad() {
        super.viewDidLoad()

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
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let date = dateFormatter.date(from: firstValue!)

            datePicker.date = date!
            changeDate(datePicker)
        } else {
            labelInput.text = "選択値：未選択"
        }
    }

    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        let assCommon = AssCommon()
        // 入力されている文字を取得する
        if labelInput.text != "選択値：未選択" {
            //let cell = myTableView?.cellForRowAtIndexPath(indexPath!)
            let myDateFormatter: DateFormatter = DateFormatter()
            myDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
            let choice: NSString = myDateFormatter.string(from: datePicker.date) as NSString
            //let choice = textInput.text

            if choice as String != firstValue {
                let array : [AnyObject] = [choice]
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
    @IBAction func changeDate(_ sender: UIDatePicker) {
        let myDateFormatter: DateFormatter = DateFormatter()
        myDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let mySelectedDate: NSString = myDateFormatter.string(from: sender.date) as NSString
        labelInput.text = "選択値：\(mySelectedDate)"
    }
    //　削除
    @IBAction func clickDelete(_ sender: AnyObject) {
        labelInput.text = "選択値：未選択"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
}
