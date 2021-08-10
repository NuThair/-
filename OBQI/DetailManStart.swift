//
//  DetailManStart.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/21.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailManStart: UIViewController, UIAlertViewDelegate {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    let appCommon = AppCommon()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func clickStart(_ sender: AnyObject) {
        appDelegate.SelectedSatisfactionNo = -1 // 最初の問題からスタートする
        let outcomeCommon = OutcomeCommon()
        outcomeCommon.move(view: self)
    }
    
    @IBAction func clickEnd(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "確認", message: "満足度調査を未実施のまま終了してもよろしいでしょうか？\n満足度調査を実施しない場合は「はい」を、後日実施する場合は「いいえ」をクリックしてください。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "はい", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            print("はい")
            let episodeID = (self.appDelegate.SelectedOutcom?["EpisodeID"].asInt)!
            let outcomeID = (self.appDelegate.SelectedOutcom?["OutcomeID"].asInt)!
            let outcomeKbn = (self.appDelegate.SelectedOutcomeKbn)!
            let url = "\(AppConst.URLPrefix)satisfaction/PostUnexecuted/\(episodeID)/\(outcomeID)/\(outcomeKbn)"
            let params: [String: AnyObject] = [:]
            let res = self.appCommon.postSynchronous(url, params: params)
            if !AppCommon.isNilOrEmpty(res.errCode) {
                AppCommon.alertMessage(controller: self, title: "エラー(\(res.errCode!))", message: "登録に失敗しました。")
            }
            self.appDelegate.EndOutcome = true
            self.performSegue(withIdentifier: "SegueManEnd",sender: self)
        })
        let cancelAction: UIAlertAction = UIAlertAction(title: "いいえ", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("いいえ")
            self.appDelegate.EndOutcome = true
            self.performSegue(withIdentifier: "SegueManEnd",sender: self)
        })
        // addActionした順に左から右にボタンが配置
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
