//
//  LoginViewController.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/14.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate {
    func login()
}

class LoginViewController: UIViewController, LoginViewControllerDelegate {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        // 戻るボタン非表示
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        // 回転する
        if UIDevice.current.orientation.isPortrait {
            let rotationValue = UIInterfaceOrientation.landscapeLeft.rawValue
            UIDevice.current.setValue(rotationValue, forKey: "orientation")
        }

        /*
        if !appDelegate.loadVersion {
            let alertController = UIAlertController(title: "エラー", message: "バージョン情報を取得できませんでした。\nインターネット接続を確認して下さい。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) {
                action in NSLog("OKボタンが押されました")
            }
            // addActionした順に左から右にボタンが配置
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
        */
    }
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func ClickLogin(_ sender: AnyObject) {
        appDelegate.LoginInfo = nil
        appDelegate.delegate = self
        performSegue(withIdentifier: "SequeLoginChild",sender: self)
    }
    func login() {
        appDelegate.IsFirst = true
        performSegue(withIdentifier: "SegueSplitView",sender: self)
        appDelegate.delegate = nil
    }
    
    
}
