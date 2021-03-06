//
//  UIColor-Extension.swift
//  DYZB
//
//  Created by 时锦 陈 on 2017/2/24.
//  Copyright © 2017年 Yun. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        
        self.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1.0)
    }
}
