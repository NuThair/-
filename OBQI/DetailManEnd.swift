//
//  DetailManEnd.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/21.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class DetailManEnd: UIViewController {
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 戻るボタン非表示
        self.navigationController!.setNavigationBarHidden(true, animated: true)
    }
    
    
    @IBAction func ClickDont(_ sender: AnyObject) {
        // トップページに戻すためフラグを立てる
        appDelegate.IsEndMan = true
        appDelegate.EndOutcome = true

        dismiss(animated: true, completion: nil)
    }
    
}
