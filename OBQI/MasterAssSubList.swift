//
//  MasterAssSubList.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/11/18.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class MasterAssSubList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    let assCommon = AssCommon()
    // 表示するテーブルビュー
    var myTableView: UITableView? = nil

    var targetSubMenuList: [JSON] = []
    // 必須が入っているか
    var isOkList : [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        
        // 選択されたグループIDのデータのみ抽出する
        let selectGroupID = appDelegate.SelectedMstAssessmentGroup!["AssMenuGroupID"]!.asInt
        for i in 0 ..< appDelegate.MstAssessmentSubGroupList!.length {
            let groupID = appDelegate.MstAssessmentSubGroupList![i]["AssMenuGroupID"].asInt
            if groupID == selectGroupID {
                targetSubMenuList.append(appDelegate.MstAssessmentSubGroupList![i])
            }
        }

        // リフレッシュコントロールを設定する。
        myTableView?.refreshControl = AppCommon.getRefreshControl(self, action: #selector(self.refreshTable), for: UIControl.Event.valueChanged)

        // Regist Notification（登録）
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(MasterAssSubList.checkRequired), name: NSNotification.Name(rawValue: "requiredAssSubList"), object: nil)
    }

    //テーブルビュー引っ張り時の呼び出しメソッド
    @objc func refreshTable(){

        //テーブルを再読み込みする。
        self.viewWillAppear(false)

        //読込中の表示を消す。
        myTableView?.refreshControl?.endRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createIsOKList()
        // 初期表示時以外は更新する
        if !appDelegate.IsFirstAssSubMenu {
            myTableView!.reloadData()
        }
        
        appDelegate.IsFirstAssSubMenu = false
    }
    func createIsOKList() {
        // 性別を取得する
        let appCommon = AppCommon()
        let gender = appCommon.getCustomerGender()
        // 入力されているアセスメントを取得する
        let assCommon = AssCommon()
        let inputAssList = assCommon.getMenuGroupInputAssessmentList()
        
        isOkList = []
        let selectGroupID = appDelegate.SelectedMstAssessmentGroup!["AssMenuGroupID"]!.asInt
        for i in 0 ..< targetSubMenuList.count {
            var isOk = true
            let subGroupID = targetSubMenuList[i]["AssMenuSubGroupID"].asInt
            for j in 0 ..< appDelegate.RequiredMstAssessmentList.count {
                var exists = false
                var requireCount = 0
                let mstItem = appDelegate.RequiredMstAssessmentList[j]
                let groupID = mstItem["AssMenuGroupID"].asInt!
                let subID = mstItem["AssMenuSubGroupID"].asInt!
                let itemID = mstItem["AssItemID"].asInt!
                let genderDSKB = mstItem["GenderDSKB"].asString!
                if selectGroupID == groupID && subGroupID == subID {
                    // 性別で絞込
                    if let gen = gender {
                        // genderDSKBが両方ではなく、自分の性別とも違う場合は対象外
                        if genderDSKB != AppConst.GenderDSKB.BOTH.rawValue && genderDSKB != gen {
                            continue
                        }
                    }
                    
                    requireCount += 1
                    //for var k = 0; k < inputAssList?.length; k += 1 {
                    for k in 0..<inputAssList!.length {
                        let trn = inputAssList![k]
                        let trnGroupID = trn["AssMenuGroupID"].asInt!
                        let trnSubID = trn["AssMenuSubGroupID"].asInt!
                        let trnItemID = trn["AssItemID"].asInt!
                        if (groupID == trnGroupID && subID == trnSubID && itemID == trnItemID) {
                            exists = true
                            break
                        }
                    }
                }
                if requireCount > 0 && !exists { // 必須が１つ以上 かつ 入力がない
                    isOk = false
                    break
                }
            }
            isOkList.append(isOk)
        }
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
        
        // 選択されたサブグループを保存する
        appDelegate.SelectedMstAssessmentSubGroup = targetSubMenuList[(indexPath as NSIndexPath).row]
        
        
        // 左側を変更
        // performSegueWithIdentifier("SegueAssMenuList",sender: self)
        
        // 詳細を変更
        AppCommon.changeDetailView(sb: storyboard!, sv: splitViewController!, storyBoardID: "AssShemaNavigationController")
    }
    
    /*
     テーブルに表示する配列の総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return targetSubMenuList.count
    }
    
    /*
     Cellに値を設定する.
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as UITableViewCell
        
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "MyCell")
        let text = targetSubMenuList[(indexPath as NSIndexPath).row]["AssMenuSubGroupName"].asString
        cell.textLabel?.text = "\(text!)"
        print(text!)
        if !isOkList[(indexPath as NSIndexPath).row] {
            cell.backgroundColor = UIColor.bad() // 必須項目が終わっていない場合は赤くする
        }
        
        return cell
        
    }

    //　secondaryの処理状況に応じて未入力項目チェック
    @objc func checkRequired() {
        self.viewWillAppear(false)
    }
}
