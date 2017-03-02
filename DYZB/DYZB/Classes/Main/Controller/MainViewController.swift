//
//  MainViewController.swift
//  DYZB
//
//  Created by 时锦 陈 on 2017/2/22.
//  Copyright © 2017年 Yun. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildVC("Home")
        addChildVC("Live")
        addChildVC("Follow")
        addChildVC("Porifile")
        
        
    }

    private func addChildVC(_ storyName : String) {
        
        // 1.通过storyboard获取控制器
        let childVC = UIStoryboard(name: storyName, bundle: nil).instantiateInitialViewController()!
        
        // 2.将childVC作为子控制器
        addChildViewController(childVC)
        
    }


}
