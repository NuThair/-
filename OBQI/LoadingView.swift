//
//  LoadingView.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/13.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class LoadingView: UIViewController {
    
    //タイマー.
    var timer : Timer!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 戻るボタン非表示
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        // タイマーで遷移
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LoadingView.transition as (LoadingView) -> () -> ()), userInfo: nil, repeats: true)
        
    }
    @objc func transition() {
        //timerが動いてるなら.timerを破棄する.
        if timer.isValid == true {
            timer.invalidate()
        }
        // バージョンを取得する
        let common = AppCommon()
        //common.loadVersion()
        
        // マスターロード処理
        common.loadMaster()
        
        
        
        //var nex : AnyObject! = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController")
        //self.presentViewController(nex as UIViewController, animated: true, completion: nil)
        
        performSegue(withIdentifier: "SegueLogin",sender: self)
    }
    
    
    
}
