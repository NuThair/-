//
//  DetailOutcome.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/19.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailOutcome: UITableViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let mySections: NSArray = ["種別"]
    let myItems: NSArray = ["本人","家族","医療機関"]
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
        
        let episodeID = appDelegate.SelectedOutcom?["EpisodeID"].asInt
        let outcomeID = appDelegate.SelectedOutcom?["OutcomeID"].asInt
        
        appDelegate.SelectedOutcom = OutcomeCommon.getOutcomeHDInfo(episodeID: episodeID!, outcomeID: outcomeID!)
        
        self.tableView.reloadData()
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
        return mySections[section] as? String
    }
    
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowIndex = (indexPath as NSIndexPath).row
        var recordKB = ""
        if rowIndex == 0 {
            appDelegate.SelectedOutcomeKbn = AppConst.OutcomeKbn.SELF.rawValue
            recordKB = appDelegate.SelectedOutcom!["SelfRecordKB"].asString!
        } else if rowIndex == 1 {
            appDelegate.SelectedOutcomeKbn = AppConst.OutcomeKbn.FAMILY.rawValue
            recordKB = appDelegate.SelectedOutcom!["FamilyRecordKB"].asString!
        } else if rowIndex == 2 {
            appDelegate.SelectedOutcomeKbn = AppConst.OutcomeKbn.MEDICAL.rawValue
            recordKB = appDelegate.SelectedOutcom!["MedicalStaffRecordKB"].asString!
        }
        // 詳細を変更
        /*
        let vc = storyboard!.instantiateViewController(withIdentifier: "ManStartNavigationController")
        // NavigationItemを移植
        var item = vc.navigationItem
        if let nc = vc as? UINavigationController {
            item = nc.topViewController!.navigationItem
        }
        
        item.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        item.leftItemsSupplementBackButton = true
        
        // ViewControllerを変更
        splitViewController?.showDetailViewController(vc, sender: self)
         */

        switch recordKB {
        case AppConst.OutcomeRecordKB.MIJISSHI.rawValue:
            performSegue(withIdentifier: "SegueOutcomeStart",sender: self)
            break
        case AppConst.OutcomeRecordKB.JISSHIZUMI.rawValue:
            performSegue(withIdentifier: "SegueOutcomeList",sender: self)
        default:
            print("エラー")
            break
        }

        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        cell.textLabel?.text = "\(myItems[(indexPath as NSIndexPath).row])"
        var value : String!
        let index = (indexPath as NSIndexPath).row
        var recordKB = ""
        if index == 0 {
            value = OutcomeCommon.getRecordKbnString(recordKbn: appDelegate.SelectedOutcom!["SelfRecordKB"].asString!)
            recordKB = appDelegate.SelectedOutcom!["SelfRecordKB"].asString!
        } else if index == 1 {
            value = OutcomeCommon.getRecordKbnString(recordKbn: appDelegate.SelectedOutcom!["FamilyRecordKB"].asString!)
            recordKB = appDelegate.SelectedOutcom!["FamilyRecordKB"].asString!
        } else if index == 2 {
            value = OutcomeCommon.getRecordKbnString(recordKbn: appDelegate.SelectedOutcom!["MedicalStaffRecordKB"].asString!)
            recordKB = appDelegate.SelectedOutcom!["MedicalStaffRecordKB"].asString!
        }

        // 右側に矢印
        switch recordKB {
        case AppConst.OutcomeRecordKB.MIJISSHI.rawValue:
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            break
        case AppConst.OutcomeRecordKB.JISSHIZUMI.rawValue:
            cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            break
        case AppConst.OutcomeRecordKB.JISSHISHINAI.rawValue:
            // 選択不可
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            break
        default:
            print("エラー")
            break
        }
        cell.detailTextLabel?.text = value
        return cell
    }
    
}
