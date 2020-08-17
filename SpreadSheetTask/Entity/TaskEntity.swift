//
//  TaskEntity.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/16/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import Foundation
import UIKit

class TaskEntity {
    var employeeId: Int = 0
    var timeId: Int = 0
    var name: String
    var id: Int
    var color: UIColor
    
    init(id: Int, employeeId: Int, timeId: Int, name: String, color: UIColor = UIColor.lightGray.withAlphaComponent(0.3)) {
        self.name = name
        self.id = id
        self.timeId = timeId
        self.employeeId = employeeId
        self.color = color
    }
}

struct TimelineEntity {
    var title: String = ""
    var id: Int = 0
}


struct EmployeeEntity {
    var name: String = ""
    var empId: Int = 0
}
