//
//  ViewController.swift
//  n1app
//
//  Created by sky on 2020/07/25.
//  Copyright © 2020 sky. All rights reserved.
//

import UIKit

class FirstCalenderViewController: UIViewController {

    @IBOutlet weak var leftCalenderImage: UIImageView!
    @IBOutlet weak var leftCalenderYearLabel: UILabel!
    @IBOutlet weak var leftCalenderMonthLabel: UILabel!
    @IBOutlet var leftCalenderWeekLabels: [UILabel]!
    
    @IBOutlet var leftCalenderDayLabels: [UILabel]!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        leftCalenderMonthLabel.text = "8"
        setLeftCalender(year: 2020, month: 8)
    }
    
    func setLeftCalender(year: Int, month: Int) {
        
        func getDate(year: Int, month: Int, day: Int = 1) -> Date{
            //月の1日を取得する
            let dateComponent = DateComponents(
                calendar: Calendar.current, year: year, month: month,
                day: day)
            let date = Calendar.current.date(from: dateComponent)!
            return date
        }
        
        
        leftCalenderYearLabel.text = "\(year)" //String(year)
        leftCalenderMonthLabel.text = "\(month)"
        
        //日付
        let date = getDate(year: year, month: month)
        
        //曜日（日曜日:1~土曜日：7）
        let weekDay = Calendar.current.component(.weekday, from: date)
        
        print(weekDay)
        
        //月の最後日を取得する
        let lastDay = Calendar.current.component(.day, from: getDate(year: year, month: month + 1, day: 0))
        
        
            
//        (0...7*6).forEach {
//            print("\($0)")
//        }
        
        var day = 1
        (0..<7*6).forEach { (i: Int) in
            leftCalenderDayLabels[i].text = ""
            if i >= weekDay - 1 && day <= lastDay {
                leftCalenderDayLabels[i].text = "\(day)"
                print("表示場所：\(i) 日付:\(day)")
                day = day + 1
            }
        }
        
        
        print("")

        
        
    }
    
}

