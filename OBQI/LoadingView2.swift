//
//  LoadingView2.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/25.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class LoadingView2: UIViewController {
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    //タイマー.
    var timer : Timer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(LoadingView2.transition as (LoadingView2) -> () -> ()), userInfo: nil, repeats: true)
        
    }
    @objc func transition() {
        //timerが動いてるなら.timerを破棄する.
        if timer.isValid == true {
            timer.invalidate()
        }
        
        // マスターロード処理
        let common = AppCommon()
        common.updateMaster()
        
        // 閉じる
        dismiss(animated: true, completion: nil)
    }
    
    
    
}
