//
//  DetailOutcomeStart.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/21.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailOutcomeStart: UIViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // 画面が表示される都度
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillApper")
        
        if appDelegate.EndOutcome == true {
            // フラグを戻す
            appDelegate.EndOutcome = false
            // 戻る
            self.navigationController!.popViewController(animated: true)
        }
    }
    
}
