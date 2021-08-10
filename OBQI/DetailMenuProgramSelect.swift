//
//  MasterProgramList.swift
//  OBQI
//
//  Created by t.o on 2017/01/26.
//  Copyright © 2017年 System. All rights reserved.
//


import UIKit

class DetailMenuProgramSelect: UITableViewController {

    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    var isManualSelect = false
    var mstMenuExceptingManual:[JSON] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Cell名の登録をおこなう.
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        // DataSourceの設定をする.
        self.tableView.dataSource = self

        // Delegateを設定する.
        self.tableView.delegate = self

        // 複数選択許可
        self.tableView.allowsMultipleSelection = true

        // 手動を除いたプログラム一覧
        mstMenuExceptingManual = (appDelegate.MstMenu?.filter{ $0.1["MenuID"].asInt! != AppConst.ManualProgram }.map{ $0.1 })!
    }

    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")
    }

    // 値を更新する
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isManualSelect {
            // 「手動」のメニューIDを保存する
            let program = AppConst.ProgramParamsFormat(
                MenuID: AppConst.ManualProgram,
                MenuName: appDelegate.MstMenu?.filter{ $0.1["MenuID"].asInt! == AppConst.ManualProgram }.first.map{ $0.1["MenuName"].asString! }
            )
            appDelegate.MenuParamsTmp.Program = [program]

        } else {
            appDelegate.MenuParamsTmp.Program = []
            self.tableView.indexPathsForSelectedRows?.forEach{
                let index = ($0 as NSIndexPath).row

                // 選択されたメニューIDを保存する
                let program = AppConst.ProgramParamsFormat(
                    MenuID: mstMenuExceptingManual[index]["MenuID"].asInt!,
                    MenuName: mstMenuExceptingManual[index]["MenuName"].asString!
                )
                appDelegate.MenuParamsTmp.Program.append(program)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /*
     テーブルに表示する配列の総数を返す.
     */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mstMenuExceptingManual.count
    }

    /*
     Cellに値を設定する.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! CustomCell
        let index = (indexPath as NSIndexPath).row

        let menuData = mstMenuExceptingManual[index]

        cell.setMainLabel(mainText: (menuData["MenuName"].asString)!)
        if let insuranceKbn = menuData["InsuranceKbn"].asString {
            cell.setSubLabel(subText: "保険区分：\(AppConst.InsuranceKbnText[Int(insuranceKbn)! - 1])")
        }

        cell.setDescriptionLabel(descriptionText: (menuData["MenuDescription"].asString)!)

        // 選択済み
        let matchCnt = appDelegate.MenuParamsTmp.Program.enumerated().filter{ $0.element?.MenuID! == menuData["MenuID"].asInt }.count
        if matchCnt > 0 {
            // チェックマークをつける
            cell.isSelected = true
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        // 権限がなければ選択不可
        if !checkMenuAuth(menuID: (mstMenuExceptingManual[index]["MenuID"].asInt)!) {
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.backgroundColor = UIColor.disabled()
        }

        return cell
    }

    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let index = (indexPath as NSIndexPath).row

        // 権限がなければ選択不可
        if !checkMenuAuth(menuID: (mstMenuExceptingManual[index]["MenuID"].asInt)!) {
            return nil
        }

        return indexPath
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        // チェックマークをつける
        cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
    }
    /*
     Cellが選択された際に呼び出される.
     */
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        // チェックマークをはずす
        cell?.accessoryType = UITableViewCell.AccessoryType.none
    }

    /*
     「手動」の登録
     */
    @IBAction func ClickAddManualProgram(_ sender: AnyObject) {
        // 手動選択フラグ
        isManualSelect = true

        // 遷移元に戻る
        _ = self.navigationController?.popViewController(animated: true)
    }

    private func checkMenuAuth(menuID:Int) -> Bool {
        return (appDelegate.MstMenuJobCategoryKB?.contains{ $0.1["MenuID"].asInt! == menuID && $0.1["JobCategoryKB"].asString! == appDelegate.LoginInfo!["JobCategoryKB"].asString! })!
    }
}

class CustomCell: UITableViewCell {

    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setMainLabel(mainText: String) {
        mainLabel.text = mainText
    }
    func setSubLabel(subText: String) {
        subLabel.text = subText
    }
    func setDescriptionLabel(descriptionText: String) {
        descriptionLabel.text = descriptionText
    }
}
