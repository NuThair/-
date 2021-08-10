//
//  DetailEpisode.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/24.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailEpisode: UITableViewController {
    
    @IBOutlet var myTableView: UITableView!
    // Tableで使用する配列を定義する.
    let episodeRestartInfoItems: NSArray = ["名称", "備考", "開始日", "再開日"]
    let episodeEndInfoItems: NSArray = ["名称", "備考", "開始日", "終了日"]
    var icItems: [JSON]?
    var outcomeItems: [JSON]?
    let logoutItems: NSArray = ["ログアウト"]
    let mySections: NSArray = ["エピソード情報", "インフォームドコンセント", "アウトカム"]
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    var episodeJson : JSON!
    var episodeKbn : String!
    @IBOutlet weak var buttonChangeStatus: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // エピソード情報の取得
        getEpisodeInfo()
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
        
        if appDelegate.ChangeEpisode == true || appDelegate.ChangeIC == true {
            // エピソード情報の取得
            getEpisodeInfo()

            // フラグを戻す
            appDelegate.ChangeEpisode = false
            appDelegate.ChangeIC = false
            
            myTableView?.reloadData()
        }
    }
    func getEpisodeInfo() {
        // エピソード情報の取得
        episodeJson = EpisodeCommon.getEpisodeInfo(selectedEipsodeID: appDelegate.SelectedEpisodeID)
        
        episodeKbn = episodeJson["EpisodeKbn"].asString!
        if episodeKbn == AppConst.EpisodeKbn.START.rawValue || episodeKbn == AppConst.EpisodeKbn.RESTART.rawValue {
            buttonChangeStatus.title = "終了"
        } else {
            buttonChangeStatus.title = "再開"
        }
        // インフォームドコンセント
        icItems = episodeJson["InformedConsentList"].asArray
        // アウトカム
        outcomeItems = episodeJson["OutcomeHDList"].asArray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mySections.count
    }
    
    /*
     セクションのタイトルを返す.
     */
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mySections[section] as? String
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = (indexPath as NSIndexPath).section
        let rowIndex = (indexPath as NSIndexPath).row
        if section == 0 {
            print("section0 Button")
            if rowIndex == 0 {
                performSegue(withIdentifier: "SegueEpisodeNameChange",sender: self)
            } else if rowIndex == 1 {
                performSegue(withIdentifier: "SegueEpisodeTextChange",sender: self)
            }
        } else if section == 1 {
            print("section1 Button")
            if rowIndex == 0 {
                performSegue(withIdentifier: "SegueICSelect",sender: self)
            } else {
                appDelegate.SelectedIC = icItems?[rowIndex - 1]
                performSegue(withIdentifier: "SegueICDetail",sender: self)
            }
        } else if section == 2 {
            print("section2 Button")
            if rowIndex == 0 {
                // アウトカム追加
                let alertController = UIAlertController(title: "確認", message: "アウトカムを追加しますか？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "追加", style: UIAlertAction.Style.default, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("追加 Button")// アセスメント完了
                    // アウトカム追加
                    let episodeID = self.appDelegate.SelectedEpisodeID!
                    let url = "\(AppConst.URLPrefix)satisfaction/PostOutcomeHD/\(episodeID)"
                    let params: [String: AnyObject] = [:]
                    let res = self.appCommon.postSynchronous(url, params: params)
                    if AppCommon.isNilOrEmpty(res.errCode) {
                        self.appDelegate.SelectedOutcom = JSON(string: res.result!) // JSON読み込み
                        self.performSegue(withIdentifier: "SegueOutcomeSelect",sender: self)
                    } else {
                        AppCommon.alertError(controller: self, result: res.result, errCode: res.errCode)
                    }
                })
                let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                    (action: UIAlertAction!) -> Void in
                    print("キャンセル")
                })
                // addActionした順に左から右にボタンが配置
                alertController.addAction(cancelAction)
                alertController.addAction(okAction)
                present(alertController, animated: true, completion: nil)

            } else {
                appDelegate.SelectedOutcom = outcomeItems![rowIndex - 1]
                performSegue(withIdentifier: "SegueOutcomeSelect",sender: self)
            }
        } else if section == 3 {
            print("section3 Button")
        }
        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return episodeRestartInfoItems.count
        } else if section == 1 {
            return icItems!.count + 1 // 追加ボタンを配置するため＋１
        } else if section == 2 {
            return outcomeItems!.count + 1 // 追加ボタンを配置するため＋１
        } else if section == 3 {
            return logoutItems.count
        } else {
            return 0
        }
    }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = (indexPath as NSIndexPath).section
        if section == 0 {
            // 表示するアイテムを変更する
            let episodeInfoItems: NSArray
            if episodeKbn == AppConst.EpisodeKbn.START.rawValue || episodeKbn == AppConst.EpisodeKbn.RESTART.rawValue {
                episodeInfoItems = episodeRestartInfoItems
            } else {
                episodeInfoItems = episodeEndInfoItems
            }
            
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(episodeInfoItems[(indexPath as NSIndexPath).row])"
            var value : String!
            let index = (indexPath as NSIndexPath).row
            if index == 0 {
                value = episodeJson["EpisodeName"].asString
                if AppCommon.isNilOrEmpty(value) {
                    value = "名称未設定"
                }
                // 右側に矢印
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            } else if index == 1 {
                value = episodeJson["EpisodeText"].asString
                // 右側に矢印
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            } else if index == 2 {
                value = AppCommon.getDateFormat(date: episodeJson["StartDate"].asDate, format: "yyyy/MM/dd HH:mm:ss")
                cell.accessoryType = UITableViewCell.AccessoryType.none
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else if index == 3 {
                value = AppCommon.getDateFormat(date: episodeJson["LastDate"].asDate, format: "yyyy/MM/dd HH:mm:ss")
                cell.accessoryType = UITableViewCell.AccessoryType.none
                cell.selectionStyle = UITableViewCell.SelectionStyle.none
            } else {
                value = ""
            }
            cell.detailTextLabel?.text = value
            //cell.selectionStyle = UITableViewCellSelectionStyle.none // 選択不可の場合
            return cell
        } else if section == 1 {
            // インフォームドコンセントを追加ボタンを配置する
            if (indexPath as NSIndexPath).row == 0 {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
                cell.textLabel?.text = "インフォームドコンセントを追加する"
                cell.textLabel?.textColor = UIColor.blue
                cell.selectionStyle = UITableViewCell.SelectionStyle.gray
                return cell
            } else {
                var value = icItems![(indexPath as NSIndexPath).row - 1]["ICText"].asString
                let icDateTime = AppCommon.getDateFormat(date: icItems![(indexPath as NSIndexPath).row - 1]["ICDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")
                let icid = icItems![(indexPath as NSIndexPath).row - 1]["ICID"].asInt!
                let icName = ICCommon.getICIDName(icid: icid)
                if AppCommon.isNilOrEmpty(value) {
                    value = "名称未設定"
                }
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MyCell")
                cell.textLabel?.text = "\(value!)"
                cell.detailTextLabel?.text = "種別：\(icName!)、追加日時：\(icDateTime!)"
                // 右側に矢印
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.selectionStyle = UITableViewCell.SelectionStyle.gray
                return cell
            }
        } else if section == 2 {
            // アウトカムを追加ボタンを配置する
            if (indexPath as NSIndexPath).row == 0 {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
                cell.textLabel?.text = "エピソードのアウトカムを追加する"
                cell.textLabel?.textColor = UIColor.blue
                cell.selectionStyle = UITableViewCell.SelectionStyle.gray
                return cell
            } else {
                let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
                cell.textLabel?.text = ""
                cell.detailTextLabel?.text = AppCommon.getDateFormat(date: outcomeItems![(indexPath as NSIndexPath).row - 1]["OutcomeDateTime"].asDate, format: "yyyy/MM/dd HH:mm:ss")
                // 右側に矢印
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                cell.selectionStyle = UITableViewCell.SelectionStyle.gray
                return cell
            }
        } else if section == 3 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(logoutItems[(indexPath as NSIndexPath).row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.textLabel?.textColor = UIColor.red
            return cell
        } else  {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            return cell
        }
    }
    
    @IBAction func ClickChangeStatus(_ sender: AnyObject) {
        if episodeKbn == AppConst.EpisodeKbn.START.rawValue || episodeKbn == AppConst.EpisodeKbn.RESTART.rawValue {
            print("終了")
            performSegue(withIdentifier: "SegueEpisodeEnd",sender: self)
        } else {
            print("再開")
            performSegue(withIdentifier: "SegueEpisodeRestart",sender: self)
        }
        
    }
    

}

