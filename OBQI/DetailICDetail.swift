//
//  DetailICDetail.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/06.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailICDetail: UITableViewController {
    @IBOutlet var myTableView: UITableView!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let icItems: NSArray = ["種別", "備考", "写真"]

    let icCommon = ICCommon()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")
        
        let episodeID = appDelegate.SelectedIC?["EpisodeID"].asInt
        let icID = appDelegate.SelectedIC?["ICID"].asInt
        let seqNo = appDelegate.SelectedIC?["SEQNO"].asInt
        
        appDelegate.SelectedIC = ICCommon.getICInfo(episodeID: episodeID!, icID: icID!, seqNo: seqNo!)
        
        myTableView?.reloadData()
    }
    
    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowIndex = (indexPath as NSIndexPath).row
        if rowIndex == 1 {
            performSegue(withIdentifier: "SegueICNameInput",sender: self)
        } else if rowIndex == 2 {
            // 右側に矢印
            performSegue(withIdentifier: "SegueICPhoto",sender: self)
        }
        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icItems.count
    }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        cell.textLabel?.text = "\(icItems[(indexPath as NSIndexPath).row])"
        var value : String!
        let index = (indexPath as NSIndexPath).row
        if index == 0 {
            value = ICCommon.getICIDName(icid: appDelegate.SelectedIC?["ICID"].asInt)
        } else if index == 1 {
            value = appDelegate.SelectedIC?["ICText"].asString
            if AppCommon.isNilOrEmpty(value) {
                value = "未設定"
            }
            // 右側に矢印
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        } else if index == 2 {
            let episodeID = appDelegate.SelectedIC?["EpisodeID"].asInt
            let icID = appDelegate.SelectedIC?["ICID"].asInt
            let seqNo = appDelegate.SelectedIC?["SEQNO"].asInt
            if (icCommon.getICPhotoFileList(episodeID: episodeID!, icID: icID!, seqNo: seqNo!)?.length)! > 0 {
                value = "有り"
            }
            // 右側に矢印
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        cell.detailTextLabel?.text = value
        //cell.selectionStyle = UITableViewCellSelectionStyle.none // 選択不可の場合
        return cell
    }
    @IBAction func clickDelete(_ sender: AnyObject) {
        // 変更値の保存変更
        let episodeID = appDelegate.SelectedIC?["EpisodeID"].asInt
        let icID = appDelegate.SelectedIC?["ICID"].asInt
        let seqNo = appDelegate.SelectedIC?["SEQNO"].asInt
        
        let url = "\(AppConst.URLPrefix)ic/DeleteInformedConsent/\(episodeID!)/\(icID!)/\(seqNo!)"
        let appCommon = AppCommon()
        let res = appCommon.deleteSynchronous(url, params: [:])
        if !AppCommon.isNilOrEmpty(res.errCode) {
            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "削除に失敗しました。")
        } else {
            // 変更されているのでフラグを更新する
            appDelegate.ChangeIC = true
        }
        
        // 戻る
        _ = navigationController?.popViewController(animated: true)
    }
    
}
