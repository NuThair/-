//
//  DetailMenuList.swift
//  OBQI
//
//  Created by t.o on 2017/01/27.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class DetailMenuDeprecatedAssessmentList: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var assessmentJson:JSON?

    @IBOutlet weak var myNaviBar: UINavigationItem!
    @IBOutlet weak var annotation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 選択不可
        self.tableView.allowsSelection = false
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")

        // 名称の取得
        let navc = self.navigationController!
        let parentView = navc.viewControllers[navc.viewControllers.count - 2] as? DetailMenuDetail
        let bLogSubGroupName = appDelegate.MstBusinessLogSubHDList?
            .filter{ $0.1["BLogGroupID"].asInt! == parentView?.selectedBLogGroupID && $0.1["BLogSubGroupID"].asInt! == parentView?.selectedBLogSubGroupID }
            .first.map{ $0.1["BLogSubGroupName"].asString! }

        myNaviBar.title = "\(bLogSubGroupName!) 非推奨項目一覧"
        annotation.text = "　\(bLogSubGroupName!)において、以下のアセスメントで注意が必要です。"

        // 非推奨アセスメント一覧
        let url = "\(AppConst.URLPrefix)menu/GetNoRecommendAssessments/\(appDelegate.MenuParams.MenuHD.MenuGroupID!)/\((parentView?.selectedBLogGroupID)!)/\((parentView?.selectedBLogSubGroupID)!)"
        let res = appCommon.getSynchronous(url)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }
        assessmentJson = JSON(string: res.result!) // JSON読み込み
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     セクションの数を返す.
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        if assessmentJson == nil {
            return 0
        }

        return (assessmentJson?.length)!
    }

    /*
     セクション設定
     */
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame: CGRect = tableView.frame
        let headerView: UIView = UIButton(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        headerView.backgroundColor = UIColor.defaultSectionBackGround()

        let label = UILabel(frame: CGRect(x: 8, y: 0, width: 400, height: 48));
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        label.numberOfLines = 0
        label.text = ""
        if assessmentJson != nil {
            let assGroupId = assessmentJson![section]["AssMenuGroupID"].asInt!
            let assSubGroupId = assessmentJson![section]["AssMenuSubGroupID"].asInt!
            let groupName =  appDelegate.MstAssessmentGroupList?.filter{ $0.1["AssMenuGroupID"].asInt! == assGroupId }.first.map{ $0.1["AssMenuGroupName"].asString! }
            let subGroupName = appDelegate.MstAssessmentSubGroupList?.filter{ $0.1["AssMenuGroupID"].asInt! == assGroupId && $0.1["AssMenuSubGroupID"].asInt! == assSubGroupId }.first.map{ $0.1["AssMenuSubGroupName"].asString! }
            label.text = "【メニュー】\(groupName!)\n【サブメニュー】\(subGroupName!)"
        }
        headerView.addSubview(label)

        return headerView
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if assessmentJson == nil {
            return 0
        }

        return assessmentJson![section]["AssAnswers"].length
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "MyCell")
        let section = (indexPath as NSIndexPath).section
        let index = (indexPath as NSIndexPath).row

        let assItem = appDelegate.MstAssessmentList?
            .filter{ $0.1["AssMenuGroupID"].asInt! == assessmentJson![section]["AssMenuGroupID"].asInt!
                && $0.1["AssMenuSubGroupID"].asInt! == assessmentJson![section]["AssMenuSubGroupID"].asInt!
                && $0.1["AssItemID"].asInt! == assessmentJson![section]["AssAnswers"][index]["AssItemID"].asInt!
            }.first?.1

        cell.textLabel?.text = assItem?["AssName"].asString

        cell.detailTextLabel?.text = "\(assessmentJson![section]["AssAnswers"][index]["AssChoiceAsrs"].map{$0.1.asString!}.joined(separator: ","))\((assItem?["AssUnit"].asString!)!)"

        return cell
    }
}


