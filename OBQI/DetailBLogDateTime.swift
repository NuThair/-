//
//  DetaInputTreatmentDateTime.swift
//  OBQI
//
//  Created by t.o on 2017/03/24.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailBLogDateTime: UIViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let bLogCommon = BLogCommon()

    var firstValue : String?

    @IBOutlet weak var InputLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!

    let defaultLabel = "選択値：未選択"

    override func viewDidLoad() {
        super.viewDidLoad()

        // 初期値を設定
        let selectedTrnBLogDT = appDelegate.trnBLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == appDelegate.SelectedBLogDT.BLogItemID
        }
        if selectedTrnBLogDT != nil && selectedTrnBLogDT!.count > 0 {
            firstValue = "選択値：\(selectedTrnBLogDT!.first.map{ $0.1["BLogChoicesAsr"].asString! }!)"
        } else {
            firstValue = defaultLabel
        }

        InputLabel.text = firstValue
    }

    /*
     戻る
     値を更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // 変更があれば更新
        if firstValue == InputLabel.text {
            return
        }

        var ansArray:[String] = []
        if InputLabel.text != defaultLabel {
            ansArray = [AppCommon.getDateFormat(date: datePicker.date, format: "yyyy/MM/dd HH:mm")!]
        }
        let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)

        // 保存のために必要なデータを生成
        let selectedBLog = AppConst.BLogDTFormat(
            BLogGroupID: appDelegate.SelectedBLogDT.BLogGroupID!,
            BLogSubGroupID: appDelegate.SelectedBLogDT.BLogSubGroupID!,
            BLogItemID: appDelegate.SelectedBLogDT.BLogItemID!
        )

        // データ保存
        bLogCommon.saveBLog(customerID, selectedBLog: selectedBLog, ansArray: ansArray, controller: self)

        // 変更フラグ
        appDelegate.BLogisChanged = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    /*
     入力内容クリア
     */
    @IBAction func clickClear(_ sender: Any) {
        datePicker.date = Date()
        InputLabel.text = defaultLabel
    }

    /*
     入力内容変更
     */
    @IBAction func changeDate(_ sender: Any) {
        InputLabel.text = "選択値：\(AppCommon.getDateFormat(date: datePicker.date, format: "yyyy/MM/dd HH:mm")!)"
    }
}
