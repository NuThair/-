//
//  LoginChildViewController.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/18.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class LoginChildViewController: UIViewController {
    @IBOutlet weak var TextClinicID: UITextField!
    @IBOutlet weak var TextStaffID: UITextField!
    @IBOutlet weak var TextPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TextClinicID.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickLogin(_ sender: AnyObject) {
        let appCommon = AppCommon()
        let clinicID = TextClinicID.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let staffID = TextStaffID.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let password = TextPassword.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if clinicID == "" || staffID == "" || password == "" {
            let alertController = UIAlertController(title: "エラー", message: "入力されていない項目があります。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        let nssStaffID:NSString = staffID! as NSString
        let nssClincicID:NSString = clinicID! as NSString
        let nssPass:NSString = password! as NSString
        
        if nssStaffID.length > 20 || nssClincicID.length > 20 || nssPass.length > 20 {
            let alertController = UIAlertController(title: "エラー", message: "20文字以内で入力してください。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)

            return
        }

        let eClinicID = clinicID!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let eStaffID = staffID!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        let ePassword = password!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

        let params: [String: AnyObject] = [
            "ShopID": eClinicID as AnyObject,
            "UserID": eStaffID as AnyObject,
            "Password": ePassword as AnyObject,
        ]
        
        let url = "\(AppConst.URLPrefix)staff/PostLogin"
        let res = appCommon.postSynchronous(url, params: params)
        if !AppCommon.isNilOrEmpty(res.errCode) {
            return
        }

        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        appDelegate.LoginInfo = JSON(string: res.result!) // JSON読み込み
        
        if appDelegate.LoginInfo?["LoginSessionKey"] == nil
            || appDelegate.LoginInfo?["LoginSessionKey"].asString == "" {
            let alertController = UIAlertController(title: "エラー", message: "ログインできませんでした。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        // ログイン権限を確認する
        let str = appDelegate.LoginInfo?["Lank"].asString!
        var rang = (str!.index(str!.startIndex, offsetBy: 0) ..< str!.index(str!.startIndex, offsetBy: 1))
        let kanri = str!.substring(with: rang)
        rang = (str!.index(str!.startIndex, offsetBy: 2) ..< str!.index(str!.startIndex, offsetBy: 3))
        let shopKanri = str!.substring(with: rang)
        rang = (str!.index(str!.startIndex, offsetBy: 3) ..< str!.index(str!.startIndex, offsetBy: 4))
        let ippan = str!.substring(with: rang)
        if kanri != "1" && shopKanri != "1" && ippan != "1"  {
            let alertController = UIAlertController(title: "エラー", message: "ログインできませんでした。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)

            return
        }
        
        // 閉じる
        self.dismiss(animated: true, completion: {
            appDelegate.delegate.login()
        })
    }
    
    @IBAction func tapScreen(_ sender: AnyObject) {
        self.view.endEditing(true);
    }
    @IBAction func clickCancel(_ sender: AnyObject) {
        // 閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
}
