//
//  DetailBLogSelectSingle.swift
//  OBQI
//
//  Created by t.o on 2017/03/24.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailBLogInputTextArea: UIViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let bLogCommon = BLogCommon()

    var firstValue = ""

    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var InputArea: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // 選択されたDTをセット
        let selectedMstBLogDT = (appDelegate.MstBusinessLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == appDelegate.SelectedBLogDT.BLogItemID
            }
            .first.map{ $0.1 })!

        // タイトルを設定
        ItemNameLabel.text = "\(selectedMstBLogDT["BLogItemName"].asString!)"

        // 初期値を設定
        let selectedTrnBLogDT = appDelegate.trnBLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == appDelegate.SelectedBLogDT.BLogItemID
        }
        if selectedTrnBLogDT != nil && selectedTrnBLogDT!.count > 0 {
            firstValue = selectedTrnBLogDT!.first.map{ $0.1["BLogChoicesAsr"].asString! }!
        }
        InputArea.text = firstValue
        InputArea.becomeFirstResponder()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     戻る
     */
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        super.viewWillDisappear(animated)

        // 変更があれば更新
        if firstValue == InputArea.text {
            return
        }

        var ansArray:[String] = []
        if !AppCommon.isNilOrEmpty(InputArea.text) {
            ansArray = [InputArea.text!]
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

    /*
     入力内容クリア
     */
    @IBAction func clickClear(_ sender: Any) {
        InputArea.text = ""
    }
}
