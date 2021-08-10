//
//  SettingViewController.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/20.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class SettingViewController: UITableViewController {
    
    // Tableで使用する配列を定義する.
    let loginInfoItems: NSArray = ["クリニック", "スタッフ"]
    let updateItems: NSArray = ["マスタ情報更新"]
    let appItems: NSArray = ["アプリ更新"]
    let logoutItems: NSArray = ["ログアウト"]
    
    // Sectionで使用する配列を定義する.
    let mySections: NSArray = [" ","ログイン情報", "マスタ情報", "アプリ更新", "ログアウト"]
    // 表示するテーブルビュー
    //var myTableView: UITableView? = nil
    
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
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 詳細切り替え
        AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "SettingNavigationController")
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
        if (indexPath as NSIndexPath).section == 1 {
            print("キャンセル")
        } else if (indexPath as NSIndexPath).section == 2 {
            AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "UpdateNavigationController")
            
            let alertController = UIAlertController(title: "確認", message: "マスタ情報を更新しますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
            // ボタンが押された時の処理を書く（クロージャ実装）
            (action: UIAlertAction!) -> Void in
                print("pushed 更新 Button")
                self.performSegue(withIdentifier: "SegueLoading",sender: self)
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })

            // addActionした順に左から右にボタンが配置
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        } else if (indexPath as NSIndexPath).section == 3 {
            print("pushed アプリ更新 Button")
            // ブラウザ起動
            let nsUrl = URL(string:"\(AppConst.UPDATE_URL)\(AppConst.HTML_NAME.DONWLOAD.rawValue)")
            UIApplication.shared.open(nsUrl!,options:[:],completionHandler:nil)
        } else if (indexPath as NSIndexPath).section == 4 {
            let alertController = UIAlertController(title: "確認", message: "ログアウトしますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ログアウト", style: UIAlertAction.Style.default, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("pushed ログアウト Button")
                self.appDelegate.LoginInfo = nil
                self.dismiss(animated: true, completion: nil)
            })
            let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
                // ボタンが押された時の処理を書く（クロージャ実装）
                (action: UIAlertAction!) -> Void in
                print("Cancel")
            })
            
            // addActionした順に左から右にボタンが配置
            alertController.addAction(cancelAction)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        // 選択を外す
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return loginInfoItems.count
        } else if section == 2 {
            return updateItems.count
        } else if section == 3 {
            return appItems.count
        } else if section == 4 {
            return logoutItems.count
        } else {
            return 0
        }
    }
    
    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath as NSIndexPath).section == 1 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value2, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(loginInfoItems[(indexPath as NSIndexPath).row])"
            var name = ""
            if (indexPath as NSIndexPath).row == 0 {
                name = appDelegate.LoginInfo!["ShopName"].asString! + "(" + String(appDelegate.LoginInfo!["ShopID"].asInt!) + ")"
            } else {
                let staffID : String! = appDelegate.LoginInfo?["UserID"].asString!
                name = appDelegate.LoginInfo!["StaffName"].asString! + "(" + staffID! + ")"
            }
            cell.detailTextLabel?.text = name
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            
            return cell
        } else if (indexPath as NSIndexPath).section == 2 {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(updateItems[(indexPath as NSIndexPath).row])"
            cell.textLabel?.textColor = UIColor.blue
            cell.selectionStyle = UITableViewCell.SelectionStyle.gray
            return cell
        } else if (indexPath as NSIndexPath).section == 3 {
            let appCommon = AppCommon()
            //let isNewVersion = appCommon.isNewVersion()
            let isNewVersion = false
            
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
            cell.textLabel?.text = "\(appItems[(indexPath as NSIndexPath).row])"
            cell.selectionStyle = UITableViewCell.SelectionStyle.blue
            if isNewVersion {
                cell.textLabel?.textColor = UIColor.blue
            } else {
                cell.textLabel?.textColor = UIColor.red
            }
            return cell
        } else if (indexPath as NSIndexPath).section == 4 {
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
    
}
