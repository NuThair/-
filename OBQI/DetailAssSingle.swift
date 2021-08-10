//
//  DetailAssSingle.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/08.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailAssSingle: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var labelAssName: UILabel!
    // 表示する値の配列.
    var choiceValues: [String] = []
    // 表示するテーブルビュー
    @IBOutlet weak var myTableView: UITableView!
    // 初期値
    var firstValue : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let assCommon = AssCommon()
        // 選択肢を取得する
        let mst = appDelegate.SelectedMstAssessmentItem!
        choiceValues = mst["AssChoices"].asString!.components(separatedBy: ",")
        // AssNameを設定する
        labelAssName.text = mst["AssName"].asString!
        let unit = mst["AssUnit"].asString
        // なぜか表示されないので暫定的に別ラベルを作成
        let label = UILabel(frame: labelAssName.frame)
        label.text = labelAssName.text
        
        if !AppCommon.isNilOrEmpty(unit) {
            label.text = "\(label.text!)(単位：\(unit!))"
        }
        // 登録されている値を取得する
        let inputValue = assCommon.getAssInput(appDelegate.InputAssList, mstAssessment: appDelegate.SelectedMstAssessmentItem)
        if inputValue.count > 0 {
            firstValue = inputValue[0]["AssChoicesAsr"].asString
        }
        // 複数選択不可
        myTableView.allowsMultipleSelection = false
        // Cell名の登録をおこなう.
        myTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        myTableView!.dataSource = self
        
        // Delegateを設定する.
        myTableView!.delegate = self
    }
    
    /*
     セクションの数を返す.
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    /*
     Cellが選択された際に呼び出される.
     */
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = UITableViewCell.AccessoryType.none
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choiceValues.count
    }
    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as UITableViewCell
        let choice = choiceValues[(indexPath as NSIndexPath).row]
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: choice)
        cell.accessoryType = UITableViewCell.AccessoryType.none
        cell.textLabel?.text = choice
        
        // 入力されている値と同じなのでチェック状態にする
        if choice == firstValue {
            cell.isSelected = true
            myTableView!.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        
        return cell
    }
    /*
     戻る
     値が変更されていたら更新する
     */
    override func viewWillDisappear(_ animated: Bool) {
        print("back")
        let assCommon = AssCommon()
        // 選択されているインデックスを取得する
        let indexPath = myTableView?.indexPathForSelectedRow
        if indexPath != nil {
            //let cell = myTableView?.cellForRowAtIndexPath(indexPath!)
            let choice = choiceValues[(indexPath! as NSIndexPath).row]
            
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
                    AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
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
    //　削除
    @IBAction func clickDelete(_ sender: AnyObject) {
        let indexPath = myTableView?.indexPathForSelectedRow
        if indexPath != nil {
            let cell = myTableView?.cellForRow(at: indexPath!)
            cell!.isSelected = false
            myTableView!.deselectRow(at: indexPath!, animated: false)
            cell!.accessoryType = UITableViewCell.AccessoryType.none
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
