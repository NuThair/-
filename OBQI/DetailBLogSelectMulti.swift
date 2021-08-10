//
//  DetailBLogSelectSingle.swift
//  OBQI
//
//  Created by t.o on 2017/03/24.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailBLogSelectMulti: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let bLogCommon = BLogCommon()

    var answerList:[String] = []
    var firstValue:[String] = []
    var currentValue:[String] = []

    @IBOutlet weak var ItemNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 複数選択可
        self.tableView.allowsMultipleSelection = true

        // 選択されたDTをセット
        let selectedMstBLogDT = (appDelegate.MstBusinessLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == appDelegate.SelectedBLogDT.BLogItemID
            }
            .first.map{ $0.1 })!

        // 選択肢を展開
        answerList = (selectedMstBLogDT["BLogChoices"].asString!).components(separatedBy: ",")

        // タイトルを設定
        ItemNameLabel.text = "　\(selectedMstBLogDT["BLogItemName"].asString!)"

        // 初期値を設定
        let selectedTrnBLogDT = appDelegate.trnBLogDTList?
            .filter{
                $0.1["BLogGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogGroupID
                    && $0.1["BLogSubGroupID"].asInt! == appDelegate.SelectedBLogDT.BLogSubGroupID
                    && $0.1["BLogItemID"].asInt! == appDelegate.SelectedBLogDT.BLogItemID
        }
        if selectedTrnBLogDT != nil && selectedTrnBLogDT!.count > 0 {
            firstValue = selectedTrnBLogDT!.map{ $0.1["BLogChoicesAsr"].asString! }
        }
        currentValue = firstValue
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
        if firstValue == currentValue {
            return
        }

        var ansArray:[String] = []
        if currentValue.count > 0 {
            ansArray = currentValue
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
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerList.count
    }
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let index = (indexPath as NSIndexPath).row

        let answerText = answerList[index]
        cell.textLabel?.text = answerText

        // 入力されている値と同じなのでチェック状態にする
        if currentValue.contains(answerText)  {
            cell.isSelected = true
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        return cell
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let index = (indexPath as NSIndexPath).row

        // 選択された値を設定
        currentValue.append(answerList[index])

        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let index = (indexPath as NSIndexPath).row

        // 選択解除された値を除外
        currentValue.remove(at: currentValue.firstIndex(of: answerList[index])!)

        cell?.accessoryType = UITableViewCell.AccessoryType.none
    }

    /*
     入力内容クリア
     */
    @IBAction func clickClear(_ sender: Any) {
        // 選択状態の解除
        let indexPaths = self.tableView.indexPathsForSelectedRows
        if indexPaths != nil && (indexPaths?.count)! > 0 {
            for i in 0 ..< indexPaths!.count {
                let indexPath: IndexPath = indexPaths![i] as IndexPath
                let cell = self.tableView.cellForRow(at: indexPath)
                cell!.isSelected = false
                self.tableView.deselectRow(at: indexPath, animated: false)
                cell!.accessoryType = UITableViewCell.AccessoryType.none
            }
            currentValue = []
        }
    }
}
