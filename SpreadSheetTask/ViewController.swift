//
//  ViewController.swift
//  SpreadSheetTask
//
//  Created by Nguyen Luan on 8/15/20.
//  Copyright © 2020 Nguyen Luan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var spreadsheetView: SpreadsheetView!
    var timelineList = Array<TimelineEntity>()
    var employeeList = Array<EmployeeEntity>()
    var taskList = Array<TaskEntity>()
    var numTaskFake: Int = 30
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        mockData()
        spreadsheetView.dataSource = self
    }
}

extension ViewController: SpreadsheetViewDataSource {
    func numberOfColumns(in spreadsheetView: SpreadsheetView) -> Int {
        return employeeList.count
    }
    
    func heightForColumHeader(in spreadsheetView: SpreadsheetView) -> CGFloat {
        return 100
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForColumItemAt indexPath: IndexPath) -> UIView? {
        let cell = HeaderColumnView.instanceFromNib()
        let empEntity = employeeList[indexPath.row]
        cell.titleLabel.text = empEntity.name
        return cell
    }
    
    func numberOfRows(in spreadsheetView: SpreadsheetView) -> Int {
        return timelineList.count
    }
    
    func widthForRowHeader(in spreadsheetView: SpreadsheetView) -> CGFloat {
        return 180
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForRowItemAt indexPath: IndexPath) -> UIView? {
        let cell = HeaderRowView.instanceFromNib()
        let timeEntity = timelineList[indexPath.row]
        cell.titleLabel.text = timeEntity.title
        return cell
    }
    
    func spreadsheetView(_ spreadsheetView: SpreadsheetView, cellForItemAt indexPath: IndexPath) -> UIView? {
        if let taskEntity = findTaskByIndexPath(indexPath: indexPath) {
            let cell = TaskView.instanceFromNib()
            cell.titleLabel.text = taskEntity.name
            cell.backgroundColor = taskEntity.color
            return cell
        }
        return nil
    }
    
    func findTaskByIndexPath(indexPath: IndexPath) -> TaskEntity? {
        if (indexPath.row < employeeList.count && indexPath.section < timelineList.count) {
            let employeeEntity = employeeList[indexPath.row]
            let timeEntity = timelineList[indexPath.section]
            let filters = taskList.filter { (taskEntity) -> Bool in
                return (taskEntity.employeeId == employeeEntity.empId && taskEntity.timeId == timeEntity.id)
            }
            return filters.first
        }
        return nil
    }
}

