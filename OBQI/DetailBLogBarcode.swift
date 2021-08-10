//
//  DetailBLogSelectSingle.swift
//  OBQI
//
//  Created by t.o on 2017/03/24.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailBLogBarcode: UIViewController, UITextFieldDelegate {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let bLogCommon = BLogCommon()

    var firstValue = ""

    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var ErrorLabel: UILabel!
    @IBOutlet weak var InputText: UITextField!

    var selectedMstBLogDT:JSON?

    override func viewDidLoad() {
        super.viewDidLoad()

        InputText.delegate = self

        // 選択されたDTをセット
        selectedMstBLogDT = (appDelegate.MstBusinessLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == appDelegate.SelectedBLogDT.BLogItemID
            }
            .first.map{ $0.1 })!

        // キーボードタイプを切り替える
        if selectedMstBLogDT?["InputValueID"].asString == AppConst.InputValueID.NUM.rawValue {
            InputText.keyboardType = UIKeyboardType.numberPad
        }

        // タイトルを設定
        var title = (selectedMstBLogDT?["BLogItemName"].asString!)!
        let unit = selectedMstBLogDT?["BLogUnit"].asString
        if !AppCommon.isNilOrEmpty(unit) {
            title += "(単位：\(unit!))"
        }
        ItemNameLabel.text = title

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
        InputText.text = firstValue
        ErrorLabel.text = ""
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

        // エラーチェック
        if ErrorLabel.text != "" {
            return
        }

        // 変更があれば更新
        if firstValue == InputText.text {
            return
        }

        var ansArray:[String] = []
        if !AppCommon.isNilOrEmpty(InputText.text) {
            ansArray = [InputText.text!]
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
     UITextFieldが編集開始された直後に呼ばれる.
     */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("textFieldDidBeginEditing: \(textField.text ?? "")")
    }

    /*
     テキストが編集された際に呼ばれる.
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let txtAfterUpdate:NSString = (self.InputText.text as NSString?)!
        let text = txtAfterUpdate.replacingCharacters(in: range, with: string)

        if text == "" {
            ErrorLabel.text = ""
            return true
        }
        if selectedMstBLogDT?["InputValueID"].asString! == AppConst.InputValueID.NUM.rawValue
        {
            let val = text.toDouble()
          //  print("val: \(val ?? default value)")
            if val == nil {
                ErrorLabel.text = "半角数値で入力してください。"
                return true
            } else {
                ErrorLabel.text = ""
                return true
            }
        }
        return true
    }
    /*
     UITextFieldが編集終了する直前に呼ばれる.
     */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("textFieldShouldEndEditing: \(textField.text ?? "")")
        return true
    }

    /*
     入力内容クリア
     */
    @IBAction func clickClear(_ sender: Any) {
        InputText.text = ""
    }

    /*
     カメラへ遷移
     */
    @IBAction func clickBarcode(_ sender: Any) {
        if AppCommon.checkCameraAuthStatus(controller: self) {
            performSegue(withIdentifier: "SegueModalBLogBarcode",sender: self)
        }
    }
}
