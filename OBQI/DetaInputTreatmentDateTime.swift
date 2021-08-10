//
//  DetaInputTreatmentDateTime.swift
//  OBQI
//
//  Created by t.o on 2017/03/24.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetaInputTreatmentDateTime: UIViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let bLogCommon = BLogCommon()

    @IBOutlet weak var datePicker: UIDatePicker!

    // 初期値
    var firstValue : String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        let date = dateFormatter.date(from: appDelegate.inputTreatmentDateTime!)

        datePicker.date = date!
    }

    /*
     戻る
     値を更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("back")

        // 選択した値のセット
        appDelegate.inputTreatmentDateTime = AppCommon.getDateFormat(date: datePicker.date, format: "yyyy/MM/dd HH:mm")

        // ヘッダーだけ登録
        let ansArray:[String] = []

        let customerID = Int(appDelegate.SelectedCustomer!["CustomerID"].asString!)

        // 保存のために必要なデータを生成
        let selectedBLog = AppConst.BLogDTFormat(
            BLogGroupID: appDelegate.SelectedBLogSub.BLogGroupID!,
            BLogSubGroupID: appDelegate.SelectedBLogSub.BLogSubGroupID!,
            BLogItemID: nil
        )

        // データ保存
        bLogCommon.saveBLog(customerID, selectedBLog: selectedBLog, ansArray: ansArray, controller: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
