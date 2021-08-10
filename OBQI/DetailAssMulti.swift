//
//  DetailAssMulti.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/08.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailAssMulti: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    @IBOutlet weak var labelAssName: UILabel!
    // 表示する値の配列.
    var choiceValues: [String] = []
    // 表示するテーブルビュー
    @IBOutlet weak var myTableView: UITableView!
    // 初期値
    var firstValue : [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let assCommon = AssCommon()
        // 選択肢を取得する
        let mst = appDelegate.SelectedMstAssessmentItem!
        choiceValues = mst["AssChoices"].asString!.components(separatedBy: ",")
        // AssNameを設定する
        labelAssName.text = mst["AssName"].asString
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
            for i in 0 ..< inputValue.count {
                let temp = inputValue[i]["AssChoicesAsr"].asString
                firstValue.append(temp!)
            }
        }
        
        // 複数選択OK
        myTableView?.allowsMultipleSelection = true
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
        if firstValue.contains(choice) {
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
        let indexPaths = myTableView?.indexPathsForSelectedRows
        if indexPaths != nil && (indexPaths?.count)! > 0 {
            var isAllContains = true
            var array : [AnyObject] = []
            //for var i = 0; i < indexPaths?.count; i += 1 {
            for i in 0 ..< indexPaths!.count {
                let choice = choiceValues[(indexPaths![i] as NSIndexPath).row]
                print("選択された値は：\(choice)")
                if !firstValue.contains(choice) {
                    isAllContains = false
                }
                array.append(choice as AnyObject)
            }
            // 数が違うか、要素が違う場合
            if firstValue.count != indexPaths?.count || !isAllContains {
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
            if firstValue.count > 0 {
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
    //　削除
    @IBAction func clickDelete(_ sender: AnyObject) {
        let indexPaths = myTableView?.indexPathsForSelectedRows
        if indexPaths != nil && (indexPaths?.count)! > 0 {
            //for var i = 0; i < indexPaths?.count; i += 1 {
            for i in 0 ..< indexPaths!.count {
                let indexPath: IndexPath = indexPaths![i] as IndexPath
                let cell = myTableView?.cellForRow(at: indexPath)
                cell!.isSelected = false
                myTableView!.deselectRow(at: indexPath, animated: false)
                cell!.accessoryType = UITableViewCell.AccessoryType.none
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
