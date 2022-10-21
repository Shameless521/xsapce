//
//  XSBaseNavViewController.swift
//  xspace
//
//  Created by Lendo on 2022/8/8.
//  Copyright © 2022 星舰. All rights reserved.
//

import UIKit

class XSBaseNavViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }


}
