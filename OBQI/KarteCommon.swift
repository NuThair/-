//
//  BLogCommon.swift
//  OBQI
//
//  Created by t.o on 2017/05/21.
//  Copyright © 2017年 System. All rights reserved.
//

import UIKit

class KarteCommon {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()

    // 全選択
    func allSelect(_ tableView: UITableView, action : ((Int, Int) -> Void)? = nil) {
        for i in 0..<tableView.numberOfSections {
            for j in 0..<tableView.numberOfRows(inSection: i) {
                let ints: [Int] = [i, j]
                let indexPath = IndexPath(indexes: ints)
                let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)

                // 引数として渡された固有アクションを実行
                if  action != nil {
                        action!(i, j)
                }

                cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            }
        }
    }

    // 全解除
    func allDeSelect(_ tableView: UITableView, action : ((Int, Int) -> Void)? = nil) {
        for i in 0..<tableView.numberOfSections {
            for j in 0..<tableView.numberOfRows(inSection: i) {
                let ints: [Int] = [i, j]
                let indexPath = IndexPath(indexes: ints)
                let cell: UITableViewCell? = tableView.cellForRow(at: indexPath)

                // 引数として渡された固有アクションを実行
                if  action != nil {
                    action!(i, j)
                }

                cell?.accessoryType = UITableViewCell.AccessoryType.none
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }


    // 数値からSOAP区分取得
    func getKarteKbn(_ index: Int) -> AppConst.KarteKbn {
        guard let karteKbn = AppConst.KarteKbn(rawValue: String(index)) else {
            return AppConst.KarteKbn.SUBJECT
        }

        return karteKbn
    }

    // 更新区分名称取得
    func getUpdateKbnName(_ updateKbn:String?) -> String {
        guard let updateKbn = updateKbn else {
            return AppConst.UpdateKbnName.NIL.rawValue
        }

        switch updateKbn {
        case "0":
            return AppConst.UpdateKbnName.ADD_OR_CHANGE.rawValue

        case "1":
            return AppConst.UpdateKbnName.DELETE.rawValue

        default:
            return AppConst.UpdateKbnName.NIL.rawValue
        }
    }

    // 最終連携時間名称生成
    func getLastLinkDateText(_ lastCooperationTime:Date?) -> String {
        var title = "最終連携日時："

        if let lastCooperationTime = lastCooperationTime {
            // 連携済
            let timeString = AppCommon.getDateFormat(date: lastCooperationTime, format: "yyyy/MM/dd HH:mm")
            title = "\(title)\(timeString!)"

        } else {
            // 未連携
            title = "\(title)\(AppConst.UpdateKbnName.NIL.rawValue)"
        }

        return title
    }

    // SOA表示用フォーマッター
    // P表示用フォーマッター
    // Order表示用フォーマッター
}
