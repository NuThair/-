//
//  OutcomeViewController.swift
//  OBQI
//
//  Created by ToyamaYoshimasa on 2016/12/27.
//  Copyright © 2016年 System. All rights reserved.
//

import UIKit

class OutcomeViewController: UIViewController {
    
    var MstOutcome : JSON!
    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // マスタを取得する
        //MstOutcome = appDelegate.MstOutcomeList![appDelegate.SelectedSatisfactionNo]
        let outcomeKbn = (self.appDelegate.SelectedOutcomeKbn)!
        MstOutcome = (appDelegate.MstOutcomeList?.enumerated().filter{ $0.element.1["OutcomeKbn"].asString == outcomeKbn }.map{ $0.element.1 })![appDelegate.SelectedSatisfactionNo]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
