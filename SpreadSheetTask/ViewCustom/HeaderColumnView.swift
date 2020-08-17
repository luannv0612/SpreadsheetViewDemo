//
//  HeaderColumnView.swift
//  SpreadSheetTask
//
//  Created by FastGo on 8/17/20.
//  Copyright © 2020 luannv. All rights reserved.
//

import UIKit

class HeaderColumnView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    
    class func instanceFromNib() -> HeaderColumnView {
        return UINib(nibName: "HeaderColumnView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HeaderColumnView
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
