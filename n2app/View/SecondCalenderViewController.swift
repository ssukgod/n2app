//
//  SecondCalenderViewController.swift
//  n1app
//
//  Created by sky on 2020/08/01.
//  Copyright © 2020 sky. All rights reserved.
//

import UIKit

class SecondCalendarViewController: UIViewController {
    
    @IBOutlet weak var contentScrollView: UIScrollView!

    var year: Int = 2020
    var month: Int = 8
    weak var contentVc: SecondCalendarContentsViewController! //weak : storyboardを解放した時点で、インスタンスを解放する
    
    let eventStore = EXEventStoreRepository.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let status = eventStore.getAuthorizationStatus()
        
        if status == .notDetermined {
            eventStore.requestCalenderAccess { (access, error) in
                print("requst calender access")
            }
        } else {
            print("status is not .notDetermined")
        }
        
        if status == .authorized {
            
        let defaultCalender = eventStore.accessDefaultCalender()
        
        }
        
        contentScrollView.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        moveContentsCenter()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        contentVc = segue.destination as? SecondCalendarContentsViewController
        contentVc.topVc = self
        
        contentVc.setContents(year: year, month: month)
    }
    
    func moveContentsCenter() {
        let frameWidth = contentScrollView.frame.width
        let contentOffset = CGPoint(x: frameWidth, y: 0)
        contentScrollView.setContentOffset(contentOffset, animated: false)
    }
}

extension SecondCalendarViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetX = scrollView.contentOffset.x
        
        var log = "スクロール中：\(contentOffsetX)"
        
        let frameWidth = contentScrollView.frame.width
        
        if contentOffsetX <= 0 {
            increaseMonth(adding: -1)
            contentVc.setContents(year: year, month: month)
            contentVc.reloadData()
            moveContentsCenter()
            log.append("(左にスクロール->位置をリセット)")
        } else if contentOffsetX >= frameWidth * 2 {
            increaseMonth(adding: 1)
            contentVc.setContents(year: year, month: month)
            print(month)
            contentVc.reloadData()
            moveContentsCenter()
            log.append("(右にスクロール->位置をリセット)")
        }
        
        print(log)
    }
    
    func increaseMonth(adding: Int) {
        let components = Calendar.current.dateComponents(
            [.year, .month], from: Utils.createDate(year: year, month: month + adding, day: 1))
        year = components.year!
        month = components.month!
    }
}

class SecondCalendarContentsViewController: UIViewController {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var centerImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    
    weak var topVc: SecondCalendarViewController!
    weak var dayCollectionLeftVc: SecondCalendarDayCollectionViewController!
    weak var dayCollectionCenterVc: SecondCalendarDayCollectionViewController!
    weak var dayCollectionRightVc: SecondCalendarDayCollectionViewController!
    
    private var year: Int!
    private var month: Int!
    //private var yearMonthLabelText = "\(year)年\(month)月"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! SecondCalendarDayCollectionViewController
        vc.topVc = topVc
        
        switch segue.identifier! {
        case "LeftMonth":
            dayCollectionLeftVc = vc
            let components = Calendar.current.dateComponents(
                [.year, .month], from: Utils.createDate(year: year, month: month - 1, day: 1))
            dayCollectionLeftVc.setContents(year: components.year!, month: components.month!)
        case "CenterMonth":
            dayCollectionCenterVc = vc
            dayCollectionCenterVc.setContents(year: year, month: month)
        case "RightMonth":
            dayCollectionRightVc = vc
            let components = Calendar.current.dateComponents(
                [.year, .month], from: Utils.createDate(year: year, month: month + 1, day: 1))
            dayCollectionRightVc.setContents(year: components.year!, month: components.month!)
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadImage()
        dayCollectionLeftVc.yearMonthLabel.text = createYearMonthLabelText(year: year, month: month - 1) //一番最初ロードされる時だけ通る。そのあとはreloadData()でロードされる
        dayCollectionCenterVc.yearMonthLabel.text = createYearMonthLabelText(year: year, month: month)
        dayCollectionRightVc.yearMonthLabel.text = createYearMonthLabelText(year: year, month: month + 1)
    }
    
    func loadImage() {
        let leftDate = Utils.createDate(year: year, month: month - 1, day: 1)
        let centerDate = Utils.createDate(year: year, month: month, day: 1)
        let rightDate = Utils.createDate(year: year, month: month + 1, day: 1)
        
        // カレンダーの画像の変更
        if let leftImageView = leftImageView,
            let centerImageView = centerImageView,
            let rightImageView = rightImageView {
            
            let imageNames = ["bg01", "bg02", "bg03"]
            // 1970年からの総月数の絶対値
            var idx = abs(Calendar.current.dateComponents([.month], from: Date.init(timeIntervalSince1970: 0),
                to: leftDate).month!)
            leftImageView.image = UIImage(named: imageNames[idx % imageNames.count])
            idx = abs(Calendar.current.dateComponents([.month], from: Date.init(timeIntervalSince1970: 0),
                to: centerDate).month!)
            print("center idx")
            centerImageView.image = UIImage(named: imageNames[idx % imageNames.count])
            idx = abs(Calendar.current.dateComponents([.month], from: Date.init(timeIntervalSince1970: 0),
                to: rightDate).month!)
            rightImageView.image = UIImage(named: imageNames[idx % imageNames.count])
        }
    }
    
    func loadYearMonthLabel() {
        
    }
    
    func setContents(year: Int, month: Int) {
        self.year = year
        self.month = month
        
        print(year) //debug
        print(month) //debug
        
        let leftDate = Utils.createDate(year: year, month: month - 1, day: 1)
        let rightDate = Utils.createDate(year: year, month: month + 1, day: 1)
        
        var components = Calendar.current.dateComponents(
            [.year, .month], from: leftDate)
        dayCollectionLeftVc?.setContents(year: components.year!, month: components.month!)
        dayCollectionCenterVc?.setContents(year: year, month: month)
        components = Calendar.current.dateComponents([.year, .month], from: rightDate)
        dayCollectionRightVc?.setContents(year: components.year!, month: components.month!)
        
        
        loadImage()
    }
    
    func reloadData() {
        dayCollectionLeftVc.weekCollectionView.reloadData()
        dayCollectionLeftVc.dayCollectionView.reloadData()
        dayCollectionLeftVc.yearMonthLabel.text = createYearMonthLabelText(year: year, month: month - 1)
        
        
        dayCollectionCenterVc.weekCollectionView.reloadData()
        dayCollectionCenterVc.dayCollectionView.reloadData()
        dayCollectionCenterVc.yearMonthLabel.text = createYearMonthLabelText(year: year, month: month)
        
        dayCollectionRightVc.weekCollectionView.reloadData()
        dayCollectionRightVc.dayCollectionView.reloadData()
        dayCollectionRightVc.yearMonthLabel.text = createYearMonthLabelText(year: year, month: month + 1)
    
    }
    
    func createYearMonthLabelText(year: Int, month: Int) -> String{
        var yearLabel = String(year)
        var monthLabel = String(month)
        
        return "\(yearLabel)年\(monthLabel)月"
    }
    
}

class SecondCalendarWeekCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var weekTitleLabel: UILabel!
    @IBOutlet weak var weekTitleLabelWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var weekTitleLabelHeightConstraint: NSLayoutConstraint!
}

class SecondCalendarDayCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var contentTableViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentTableViewHeightConstraint: NSLayoutConstraint!
}

class SecondCalendarContentTableViewCell: UITableViewCell {
    @IBOutlet weak var dayTitleLabel: UILabel!
}

class SecondCalendarDayCollectionViewController: UIViewController {
    
    
    //コレクションビューの日付
    //Day Collection View -> セルの集まり
    //SecondCalendarDayCollectionViewCell -> セル
    struct DayEntity {
        var date: Date! //日付
        var dayTitle: String! //表示する日付のテキスト 例：26日
        var dayTitleColorName: String! //土曜日とか日曜日とか日付ラベルのカラー
        var events: [String] = []
    }
    
    struct WeekEntity {
        var weekTitle: String! //土　とか
        var weekTitleColorName: String! //ラベルのカラー
    }

    
    @IBOutlet weak var yearMonthLabel: UILabel!
    @IBOutlet weak var weekCollectionView: UICollectionView!
    @IBOutlet weak var dayCollectionView: UICollectionView!

    weak var topVc: SecondCalendarViewController!
        
    private var year: Int!
    private var month: Int!
    private let daysCollectionColCount: CGFloat = 7
    private var daysCollectionRowCount: CGFloat = 6
    private var days = [DayEntity]() // private var days:[DayEntity] = [] ,  private var days:[DayEntity] = Array<WeekEntity>()
    private var weeks = [WeekEntity]()
    
    
    func setContents(year: Int, month: Int) {
        self.year = year
        self.month = month
        
        //print(year)
        //print(month)
        
        weeks = createWeeks() //viewが持つ。modelから値を取得して、セルの表示タイミングでこれが呼ばれる
        days = createDays(year: year, month: month) //viewが持つ
        //print(days)  //debug
    }
    
    override func loadView() {
        super.loadView()
        
        //weeks = createWeeks() //viewが持つ。modelから値を取得して、セルの表示タイミングでこれが呼ばれる
        //days = createDays(year: 2026, month: 2) //viewが持つ
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weekCollectionView.delegate = self
        weekCollectionView.dataSource = self
        
        dayCollectionView.delegate = self
        dayCollectionView.dataSource = self
        
        //print("days=\(days)") //debug
    }
    
    func createWeeks() -> [WeekEntity] {
        
        //weekEntityのインスタンス生成(曜日を入れるための配列)
        var weeks: [WeekEntity] = []
        // 曜日を入れるための配列
//        var weekDay: [String] = []
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja")
        
        for i in 0...6 {
            //カレンダーのセルごとにDayEntityを生成
            var week: WeekEntity = WeekEntity()
            //shortWeekdaySymbolsは日曜日:0~土曜日:6
            week.weekTitle = String(formatter.shortWeekdaySymbols[i])
            
            switch i {
            case 0:
                //日曜日の場合赤
                week.weekTitleColorName = "calender_sunday_label_color"
            
            case 6:
                //土曜日の場合青
                week.weekTitleColorName = "calender_saturday_label_color"
            
            default:
                week.weekTitleColorName = "calender_default_label_color"
            }
            
            //配列化する
            weeks.append(week)
        }
        
        //print(weeks) //debug
        return weeks
    }

    
    func createDays(year: Int, month: Int) -> [DayEntity] {
        
        // 1.年と月から日付を求める. 2020年8月の場合、2020年8月1日がdateになる
        let date = Utils.createDate(year: year, month: month)
        //print(date) //debug
        
        // 2.日付から曜日を求める
        // 曜日(日曜日:1〜土曜日:7)
        // 2020年８月の場合、2020年7月31日の曜日は金曜日
        // メモ：Calendar.current.component(xxx) - dateのデータからweekday（曜日）の情報を切り取ってくれる
        let weekDay = Calendar.current.component(.weekday, from: date)
        //print(weekDay) //debug
        
        // 3.月の最後の日付を求める day=0の場合その前の月の最後の日付になる
        let currentMonthlastDay = Calendar.current.component(.day, from: Utils.createDate(year: year, month: month + 1, day: 0))
        //print(currentMonthlastDay) //debug
        
        // 前月の最後の日付を求める
        let lastMonthlastDay = Calendar.current.component(.day, from: Utils.createDate(year: year, month: month, day: 0))
        //print(lastMonthlastDay) //debug
        

        // 4.カレンダー表示のセルごとの繰り返しを行う。
        //daysCollectionRowCountを求める
        var lineNumber = (Int(weekDay) - 1 + Int(currentMonthlastDay)) / Int(daysCollectionColCount)
        if ((Int(weekDay) - 1 + Int(currentMonthlastDay)) % Int(daysCollectionColCount) > 0) {
            lineNumber = lineNumber + 1
        }
        daysCollectionRowCount = CGFloat(lineNumber)
        
        //daysCollectionRowCountを利用して、その月の必要なセル数を求める
        let cellCount = Int(daysCollectionColCount*daysCollectionRowCount)
        
        //DayEntityのインスタンス生成
        var days: [DayEntity] = []
        
        //現在の月が始まるまでのセル数（1日が土曜日(7)の場合、日曜日(1)~金曜日(6)までのセル数は6）
        // numが０の場合、その月は1日が日曜日
        let num = Int(weekDay) - 1

        // 5-1.（最後の日付または区切りがいい土曜日）まで繰り返す
        var dateInfo : Date = date //初期化
        
        //セルの最初の日のdate形式情報を生成
        switch num {
        //最初のセルが1日である場合
        case 0:
            //現在の月のdayTitleは１日から始まる
            dateInfo = Utils.createDate(year: year, month: month , day: 1)
            print(dateInfo) //debug
            break
            
        //最初のセルが1日ではない場合
        default:
            //現在の月のdayTitleは前月のどこかの日付から始まる
            //例えば、(8月)1日が土曜日の場合、日曜日~金曜日までは前月になるので(7月)26日が今月のセルに初めて表示される）
            dateInfo = Utils.createDate(year: year, month: month - 1 , day: lastMonthlastDay - num + 1)
            //print(dateInfo) //debug
        }
        
        //カレンダーのセルごとにDayEntityを生成
        var day: DayEntity = DayEntity()
        var currentDay = dateInfo //現在のdate
        for i in 0...cellCount - 1 {
            
            //date情報をDayEntityへ挿入
            day.date = currentDay
            
            //そのdayのdate形式情報から日付のラベル情報を生成
            var currentDayNumber = Calendar.current.component(.day, from: currentDay)
            //print(currentDayNumber) //debug
            
            //daytitleをDayEntityへ挿入
            day.dayTitle = String(currentDayNumber)
            
            //そのdayのdate形式情報から曜日情報を生成
            var weekdayInfo = Calendar.current.component(.weekday, from: currentDay)
            //print(weekdayInfo) //debug
            //曜日の色情報をDayEntityへ挿入
            day.dayTitleColorName = setDayTitleColor(year: year, month: month, currentDay: currentDay, weekdayInfo: weekdayInfo)
            
            //次の日を求める
            var nextday = Calendar.current.date(byAdding: .day, value: 1, to: currentDay)
            //print(nextday)
            currentDay = nextday!
            
            days.append(day)
        }
        //print(days) //debug
        return days
        
    }
    
    
    /// 日付のラベルの色を計算する
    /// 小さい値を月または日に指定すると、年と月を調整した日付を返す。
    /// 例）2020/09/00 -> 2020/08/31
    func setDayTitleColor(year: Int, month: Int, currentDay: Date, weekdayInfo: Int) -> String {
        
        var todayMonthInfo = Calendar.current.component(.month, from: currentDay)
        
        if month == todayMonthInfo  {
            switch weekdayInfo {
                //1 : 日曜日
                case 1:
                return "calender_sunday_label_color"
                
                //7 : 土曜日
                case 7:
                return "calender_saturday_label_color"
                
                default:
                return "calender_default_label_color"
            }
        } else {
            return "calender_nocurrentmouth_label_color"
        }
    }
    
}

extension SecondCalendarDayCollectionViewController: UICollectionViewDelegate {
    //コレクションビューのセルを選択
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("コレクションビューのセル選択")
    }
    
}

extension SecondCalendarDayCollectionViewController: UICollectionViewDataSource {
    
    //SecondCalendarDayCollectionViewCellのセル数を計算（必須関数）
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch collectionView {
        case weekCollectionView:
            return Int(daysCollectionColCount)
        case dayCollectionView:
            return Int(daysCollectionColCount * daysCollectionRowCount)
        default:
            return 0
        }
        
    }
    
    //SecondCalendarDayCollectionViewCellのセルの内容（表示項目とか、デザインとか？）を計算（必須関数）
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch collectionView {
        case weekCollectionView:
            let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SecondCalendarWeekCollectionViewCell",
            for: indexPath) as! SecondCalendarWeekCollectionViewCell
                       
                cell.weekTitleLabel.layer.borderColor = UIColor.black
                    .withAlphaComponent(0.2).cgColor
                cell.weekTitleLabel.layer.borderWidth = 0.25
                let size = getWeekCollectionCellSize(indexPath: indexPath)
                cell.weekTitleLabelWidthConstraint.constant = size.width
                cell.weekTitleLabelHeightConstraint.constant = size.height
            cell.weekTitleLabel.text = weeks[indexPath.row].weekTitle
            cell.weekTitleLabel.textColor = cell.weekTitleLabel.textColor == nil ? UIColor(named: "calender_default_label_color") : UIColor(named: weeks[indexPath.row].weekTitleColorName)
            
            return cell
            
        case dayCollectionView:
            let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "SecondCalendarDayCollectionViewCell",
            for: indexPath) as! SecondCalendarDayCollectionViewCell
            
                cell.contentTableView.layer.borderColor = UIColor.black
                        .withAlphaComponent(0.2).cgColor
                cell.contentTableView.layer.borderWidth = 0.25
                let size = getDayCollectionCellSize(indexPath: indexPath)
                cell.contentTableViewWidthConstraint.constant = size.width
                cell.contentTableViewHeightConstraint.constant = size.height
                cell.contentTableView.tag = indexPath.row
                cell.contentTableView.delegate = self
                cell.contentTableView.dataSource = self
                cell.contentTableView.reloadData()

            return cell
        
        default:
            return UICollectionViewCell()
        }
    }
    
    func getDayCollectionCellSize(indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        
        // セルのサイズを求める。
        
        //dayCollectionViewのサイズ
        let width = dayCollectionView.frame.width
        //let height = dayCollectionView.frame.height
        
        //dayCollectionViewCellのwidthの定数サイズ
        var dayCollectionViewCellWidthSize = Int(dayCollectionView.frame.width/daysCollectionColCount)
        
        //dayCollectionViewCellのwidthの余りサイズ
        let widthRemainder = Int(width.truncatingRemainder(dividingBy: daysCollectionColCount))
        
        //dayCollectionViewCellのHeightの定数サイズ
        var dayCollectionViewCellHeightSize = Int(dayCollectionView.frame.height/daysCollectionRowCount)
        
        //dayCollectionViewCellのHeightの余りサイズ
        let heightRemainder = Int(width.truncatingRemainder(dividingBy: daysCollectionRowCount))
        
        //dayCollectionViewCellが何行目かを区分するための数値
        let num = CGFloat(indexPath.row).truncatingRemainder(dividingBy: daysCollectionColCount)
        
        //dayCollectionViewCellのwidthの余りによって、セル（行）の大きさを調整
        if Int(num) <= widthRemainder - 1 {
            dayCollectionViewCellWidthSize = dayCollectionViewCellWidthSize + 1
        }
        
        //dayCollectionViewCellのheightの余りによって、セル(列)の大きさを調整
        if indexPath.row <= Int(daysCollectionColCount)*heightRemainder - 1 {
             dayCollectionViewCellHeightSize = dayCollectionViewCellHeightSize + 1
        }
        
        size = CGSize(width: dayCollectionViewCellWidthSize, height: dayCollectionViewCellHeightSize)

        return size
    }
    
    func getWeekCollectionCellSize(indexPath: IndexPath) -> CGSize {
        var size = CGSize()
        
        // セルのサイズを求める。
        
        //weekCollectionViewのサイズ
        let width = weekCollectionView.frame.width
        let weekCollectionViewCellHeightSize = Int(weekCollectionView.frame.height)
        
        //weekCollectionViewCellのwidthの定数サイズ
        var weekCollectionViewCellWidthSize = Int(weekCollectionView.frame.width/daysCollectionColCount)
        
        //weekCollectionViewCellのwidthの余りサイズ
        let widthRemainder = Int(width.truncatingRemainder(dividingBy: daysCollectionColCount))
        
        //weekCollectionViewCellが何行目かを区分するための数値
        let num = CGFloat(indexPath.row).truncatingRemainder(dividingBy: daysCollectionColCount)
        
        //weekCollectionViewCellのwidthの余りによって、セル（行）の大きさを調整
        if Int(num) <= widthRemainder - 1 {
            weekCollectionViewCellWidthSize = weekCollectionViewCellWidthSize + 1
        }
        
        size = CGSize(width: weekCollectionViewCellWidthSize, height: weekCollectionViewCellHeightSize)

        return size
    }
    
}

extension SecondCalendarDayCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case weekCollectionView:
            return getWeekCollectionCellSize(indexPath: indexPath)
        case dayCollectionView:
            return getDayCollectionCellSize(indexPath: indexPath)
        default:
            return CGSize.zero
        }
    }
}

extension SecondCalendarDayCollectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 14.5
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension SecondCalendarDayCollectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "SecondCalendarContentTableViewCell",
            for: indexPath) as! SecondCalendarContentTableViewCell
        
        cell.dayTitleLabel.text = days[tableView.tag].dayTitle
        cell.dayTitleLabel.textColor = UIColor(named: days[tableView.tag].dayTitleColorName ?? "calender_default_label_color") //日付の色を設定

        //print(cell.dayTitleLabel.text) //日付のラベルが合っているのかdebug
        
        return cell
    }
}




