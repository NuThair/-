//
//  MasterPatientMenu.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/25.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class MasterPatientMenu: UITableViewController {
    
    // Tableで使用する配列を定義する.
    let episodeItems: NSArray = ["エピソード一覧"]
    let assItems: NSArray = ["アセスメント一覧"]
    let menuItems: NSArray = ["介入計画一覧"]
    let bLogItems: NSArray = ["介入結果一覧"]
    let karteCooperationItems: NSArray = ["電子カルテ連携"]
    
    // Sectionで使用する配列を定義する.
    let mySections: NSArray = ["エピソード", "アセスメント", "介入計画", "介入結果", "電子カルテ連携"]
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        
        // DataSourceの設定をする.
        self.tableView.dataSource = self
        
        // Delegateを設定する.
        self.tableView.delegate = self
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
        if (indexPath as NSIndexPath).section == 0 {
            print("エピソード")
            // 遷移
            performSegue(withIdentifier: "SegueEpisodeList",sender: self)
            // 詳細を変更
            AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "EpisodeSelectNavigationController")
            return

        } else if (indexPath as NSIndexPath).section == 1 {
            print("アセスメント")
            // 遷移
            performSegue(withIdentifier: "SegueAssList",sender: self)
            return

        } else if (indexPath as NSIndexPath).section == 2 {
            print("介入計画")
            // 遷移
            performSegue(withIdentifier: "SegueReferenceMenu",sender: self)
            // 詳細を変更
            AppCommon.changeDetailView(sb: UIStoryboard(name: "Menu", bundle: nil), sv: splitViewController!, storyBoardID: "MenuDetailStartView")
            return

        } else if (indexPath as NSIndexPath).section == 3 {
            print("介入結果")
            // 遷移
            performSegue(withIdentifier: "SegueReferenceBLog",sender: self)
            // 詳細を変更
            AppCommon.changeDetailView(sb: UIStoryboard(name: "BLog", bundle: nil), sv: splitViewController!, storyBoardID: "BLogDetailStartView")
            return

        } else if (indexPath as NSIndexPath).section == 4 {
            print("電子カルテ連携")
            // 遷移
            performSegue(withIdentifier: "SegueReferenceKarteLink",sender: self)
            // 詳細を変更
            AppCommon.changeDetailView(sb: UIStoryboard(name: "KarteLink", bundle: nil), sv: splitViewController!, storyBoardID: "KarteLinkDetailStartView")
            return

        }
        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return episodeItems.count
        } else if section == 1 {
            return assItems.count
        } else if section == 2 {
            return menuItems.count
        } else if section == 3 {
            return bLogItems.count
        } else if section == 4 {
            return karteCooperationItems.count
        } else {
            return 0
        }
    }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 0 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(episodeItems[(indexPath as NSIndexPath).row])"
            cell.textLabel?.textColor = UIColor.blue
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            return cell
        } else if (indexPath as NSIndexPath).section == 1 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(assItems[(indexPath as NSIndexPath).row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.textLabel?.textColor = UIColor.blue
            return cell
        } else if (indexPath as NSIndexPath).section == 2 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(menuItems[(indexPath as NSIndexPath).row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.textLabel?.textColor = UIColor.blue
            return cell
        } else if (indexPath as NSIndexPath).section == 3 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(bLogItems[(indexPath as NSIndexPath).row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.textLabel?.textColor = UIColor.blue
            return cell
        } else if (indexPath as NSIndexPath).section == 4 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(karteCooperationItems[(indexPath as NSIndexPath).row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            cell.textLabel?.textColor = UIColor.blue
            return cell
        } else  {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            return cell
        }
    }
    
}
