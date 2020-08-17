//
//  TimelineView.swift
//  SpreadSheetTask
//
//  Created by FastGo on 8/17/20.
//  Copyright © 2020 luannv. All rights reserved.
//

import UIKit

class HeaderRowView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    
    class func instanceFromNib() -> HeaderRowView {
        return UINib(nibName: "HeaderRowView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HeaderRowView
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
