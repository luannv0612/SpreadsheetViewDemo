//
//  ViewController+MockData.swift
//  SpreadSheetTask
//
//  Created by FastGo on 8/17/20.
//  Copyright © 2020 luannv. All rights reserved.
//

import Foundation
import UIKit

extension ViewController {
    func mockData() {
            // add employee list
            employeeList.append(EmployeeEntity(name: "Hoàng Hải", empId: 1))
            employeeList.append(EmployeeEntity(name: "Nguyễn Tiến Dũng", empId: 2))
            employeeList.append(EmployeeEntity(name: "Nguyễn Viết Long", empId: 3))
            employeeList.append(EmployeeEntity(name: "Nguyễn Hải Sơn", empId: 4))
            employeeList.append(EmployeeEntity(name: "Lê Thu Hà", empId: 5))
            employeeList.append(EmployeeEntity(name: "Dr.Thanh", empId: 6))
            employeeList.append(EmployeeEntity(name: "Cristiano Ronaldo", empId: 7))
            employeeList.append(EmployeeEntity(name: "Lionel Messi", empId: 8))
            employeeList.append(EmployeeEntity(name: "Nguyến Tiến Điệp", empId: 9))
            employeeList.append(EmployeeEntity(name: "Nguyến Nhật Minh", empId: 10))
            
            // add Timeline list
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
            var timelineId = 0
            
            let dateTimeStart = formatter.date(from: "2020/08/17 9:00")
            let dateTimeEnd = formatter.date(from: "2020/08/17 12:00")
            
            var timeStartTask = dateTimeStart
            guard var timeEndTask = timeStartTask?.addingTimeInterval(15*60) else { return }
            
            formatter.dateFormat = "HH:mm"
            
            while (dateTimeEnd?.compare(timeEndTask) == .orderedDescending) {
                let title = formatter.string(from: timeStartTask!) + " - " + formatter.string(from: timeEndTask)
                timelineList.append(TimelineEntity(title: title, id: timelineId))
                timelineId += 1
                timeStartTask = timeEndTask
                if let timeEnd = timeStartTask?.addingTimeInterval(15*60) {
                    timeEndTask = timeEnd
                }
            }
    //        print(timelineList)
            
            // Random Task
            let arrayTaskName = [
                "Trồng rau ngoài vườn",
                "Dắt chó đi dạo",
                "Quay gà đồi chạy bộ",
                "Tắm cho chó",
                "Đi chăn bò",
                "Bắt ve cho chó",
                "Đi chơi với ny",
                "Chạy grab 1 tuần",
                "Vá đường quốc lộ",
                "Sửa chữa máy tính",
                "Đọc báo buổi sáng",
                "Báo cáo hàng tuần",
                "Trà tiền lương cho nhân viên",
                "Đưa nhân viên tiền đi hát",
                "Thưởng cho nhân viên đi du lịch",
                "Đi câu cá cùng sếp ngoài sông hồng, đi hát karaoke, mát xa"
            ]
            for index in 0...numTaskFake {
                // random Timeline
                let indexTimeline = Int.random(in: 0...timelineList.count-1)
                let timelineEntity = timelineList[indexTimeline]
                let indexTaskName = Int.random(in: 0...arrayTaskName.count-1)
                
                // random employee
                var isFound = false
                while (isFound == false) {
                    let indexEmployee = Int.random(in: 0...employeeList.count-1)
                    let employeeEntity = employeeList[indexEmployee]
                    let filters = taskList.filter { (taskEntity) -> Bool in
                        return (taskEntity.timeId == timelineEntity.id && employeeEntity.empId == taskEntity.employeeId)
                    }
                    if filters.count == 0 {
                        taskList.append(TaskEntity(id: index, employeeId: employeeEntity.empId, timeId: timelineEntity.id, name: arrayTaskName[indexTaskName], color: UIColor.random()))
                        isFound = true
                    }
                }
            }
        }
}
