//
//  DetailEpisodeRestart.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/29.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailEpisodeRestart: UITableViewController {
    @IBOutlet var myTableView: UITableView!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let episodeItems: NSArray = ["再開理由", "再開日"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 変更モードの切り替え
        appDelegate.EpisodeStatusChangeMode = AppConst.EpisodeChangeMode.RESTART.rawValue
        appDelegate.EpisodeRestartReason = nil
        appDelegate.EpisodeRestartDate = nil

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
        if rowIndex == 0 {
            performSegue(withIdentifier: "SegueEpisodeRestartTextChange",sender: self)
        } else if rowIndex == 1 {
            performSegue(withIdentifier: "SegueEpisodeRestartDateChange",sender: self)
        }
        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        cell.textLabel?.text = "\(episodeItems[(indexPath as NSIndexPath).row])"
        var value : String!
        let index = (indexPath as NSIndexPath).row
        if index == 0 {
            value = getReason()
            
            // 右側に矢印
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        } else if index == 1 {
            value = getDate()
            // 右側に矢印
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        cell.detailTextLabel?.text = value
        //cell.selectionStyle = UITableViewCellSelectionStyle.none // 選択不可の場合
        return cell
    }
    @IBAction func clickChangeStatus(_ sender: AnyObject) {
       
        // api/episode/PutRestartEpisode
        let url = "\(AppConst.URLPrefix)episode/PostRestartEpisode"
        let params: [String: AnyObject] = [
            "EpisodeID": String(describing: appDelegate.SelectedEpisodeID!) as AnyObject,
            "EpisodeKbn": AppConst.EpisodeKbn.RESTART.rawValue as AnyObject,
            "EpisodeDate": appDelegate.EpisodeRestartDate! as AnyObject,
            "EpisodeChangeReason": appDelegate.EpisodeRestartReason! as AnyObject,
            ]
        let appCommon = AppCommon()
        let res = appCommon.postSynchronous(url, params: params)

        if AppCommon.isNilOrEmpty(res.errCode) {
            // 変更フラグを立てる
            appDelegate.ChangeEpisode = true
            // 戻る
            _ = navigationController?.popViewController(animated: true)
        } else {
            AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "更新に失敗しました。\n再開日付は前回の終了日付より後の日付を設定してください。")
        }
    }
    
    func getReason() -> String! {
        var value : String!
        if AppCommon.isNilOrEmpty(appDelegate.EpisodeRestartReason) {
            value = "未設定"
        } else {
            value = appDelegate.EpisodeRestartReason!
        }
        return value
    }
    func getDate() -> String! {
        var value : String!
        if AppCommon.isNilOrEmpty(appDelegate.EpisodeRestartDate) {
            value = "未設定"
        } else {
            value = appDelegate.EpisodeRestartDate!
        }
        return value
    }
    
}
