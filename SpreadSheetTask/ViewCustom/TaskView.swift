//
//  TaskView.swift
//  SpreadSheetTask
//
//  Created by FastGo on 8/17/20.
//  Copyright © 2020 luannv. All rights reserved.
//

import UIKit

class TaskView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
       
       class func instanceFromNib() -> TaskView {
           return UINib(nibName: "TaskView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! TaskView
       }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
