//
//  MasterAssInputList.swift
//  OBQI
//
//  Created by t.o on 2017/01/20.
//  Copyright © 2017年 System. All rights reserved.
//
import UIKit

class MasterAssInputList: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Tableで使用する配列を定義する.

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)

    // 表示するテーブルビュー
    var myTableView: UITableView? = nil

    // 対象のメニュー
    var currentMstList : [JSON]! = []

    override func viewDidLoad() {
        super.viewDidLoad()


        // 入力されているアセスメントを取得する
        let assCommon = AssCommon()
        let inputAssList = assCommon.getInputAssessmentList()

        currentMstList = []
        //for var i = 0; i < appDelegate.MstAssessmentGroupList?.length; i += 1 {
        for i in 0 ..< appDelegate.MstAssessmentGroupList!.length {
            var exists = false
            let mstMenuGroupID = appDelegate.MstAssessmentGroupList![i]["AssMenuGroupID"].asInt!
            //for var j = 0; j < inputAssList?.length; j += 1 {
            for j in 0 ..< inputAssList!.length {
                let assMenuGroupID = inputAssList?[j]["AssMenuGroupID"].asInt
                if mstMenuGroupID == assMenuGroupID {
                    exists = true
                    break
                }
            }
            if exists {
                currentMstList.append(appDelegate.MstAssessmentGroupList![i])
            }
        }

        // TableViewの生成( status barの高さ分ずらして表示 ).
        myTableView = UITableView(frame: CGRect(x: 0, y: appDelegate.barHeight!, width: appDelegate.tabBarWidth!, height: appDelegate.availableViewHeight!), style: UITableView.Style.plain)

        // Cell名の登録をおこなう.
        myTableView!.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        myTableView!.dataSource = self

        // Delegateを設定する.
        myTableView!.delegate = self

        // Viewに追加する.
        self.view.addSubview(myTableView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

        appDelegate.SelectedMstAssessmentGroup = currentMstList[(indexPath as NSIndexPath).row].asDictionary

        // 左側を変更
        performSegue(withIdentifier: "SegueAssInputSubList",sender: self)
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMstList.count
    }

    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let text = currentMstList[(indexPath as NSIndexPath).row]["AssMenuGroupName"].asString!
        cell.textLabel?.text = "\(text)"

        return cell
        
    }
    
}
