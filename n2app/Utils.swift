//
//  Utils.swift
//  n1app
//
//  Created by sky on 2020/10/10.
//  Copyright © 2020 sky. All rights reserved.
//

import Foundation

class Utils {
    /// 年と月から日付型を作成する。実際の数字より、
    /// 小さい値を月または日に指定すると、年と月を調整した日付を返す。
    /// 例）2020/09/00 -> 2020/08/31
    static func createDate(year: Int, month: Int = 1, day: Int = 1) -> Date {
        let dateComponent = DateComponents(
            calendar: Calendar.current,
            year: year, month: month, day: day)
        let date = Calendar.current.date(from: dateComponent)!
        return date
    }
    
}
