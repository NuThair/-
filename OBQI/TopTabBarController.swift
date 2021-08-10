//
//  TopTabBarController.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/10/20.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class TopTabBarController : UITabBarController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 最初は設定画面を表示する
        if appDelegate.IsFirst {
            
            self.selectedIndex = 0
            //appDelegate.IsFirst = false
        }
    }
}
