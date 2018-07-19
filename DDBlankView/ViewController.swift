//
//  ViewController.swift
//  DDBlankView
//
//  Created by WY on 2018/7/19.
//  Copyright © 2018年 WY. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DDErrorView(superView: self.view, error: DDError.noExpectData("无相应数据")).automaticRemoveAfterActionHandle = {
            print("点击刷新")
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

