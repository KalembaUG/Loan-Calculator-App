// Created 27/01/22

import Alamofire
import FSCalendar
import JTMaterialSpinner
import UIKit
class CalendarVC: UIViewController {
    var userVC: UserVC!
    var homeVC: HomeVC!
    var settingVC: SettingVC!
    var updateincomeVC: UpdateIncomeVC!
    var updateliabilityVC: UpdateLiabilityVC!

    var user_id = ""
    @IBOutlet var liabilityTBHeight: NSLayoutConstraint!
    @IBOutlet var incomeTBHeight: NSLayoutConstraint!
    @IBOutlet var constraintCalendarHeight: NSLayoutConstraint!
    @IBOutlet var incomeTB: UITableView!
    @IBOutlet var liabilityTB: UITableView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var calendarView: FSCalendar!
    @IBOutlet var incomeTotalLabel: UILabel!
    @IBOutlet var liabilityTotalLabel: UILabel!
    @IBOutlet var finalAmountLabel: UILabel!
    var currentdate = ""

    var spinnerView = JTMaterialSpinner()

    let allIncomeCategory = Global.allIncomeCategory
    let allLiabilityCategory = Global.allLiabilityCategory
    var allIncome = [Income]()
    var allLiability = [Liability]()
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange: [Date]?
    fileprivate let gregorian = Calendar(identifier: .gregorian)
    fileprivate var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        view.addSubview(spinnerView)
        spinnerView.beginRefreshing()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.loadInitalData()
        }
    }

    func loadInitalData() {
        user_id = UserDefaults.standard.string(forKey: "userID") ?? "1"
        calendarView.register(DateCell.self, forCellReuseIdentifier: "cell")
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.allowsMultipleSelection = true
        calendarView.appearance.headerSeparatorColor = .red
        calendarView.placeholderType = .fillHeadTail
        calendarView.calendarHeaderView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        calendarView.calendarWeekdayView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.1)
        calendarView.appearance.eventOffset = CGPoint(x: 0, y: -7)

        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        currentdate = dateFormatterGet.string(from: Date())
        incomeTB.delegate = self
        incomeTB.dataSource = self
        incomeTB.register(UINib(nibName: "IncomeCell", bundle: nil), forCellReuseIdentifier: "cell")
        incomeTB.isUserInteractionEnabled = false

        liabilityTB.delegate = self
        liabilityTB.dataSource = self
        liabilityTB.register(UINib(nibName: "LiabilityCell", bundle: nil), forCellReuseIdentifier: "cell")
        liabilityTB.isUserInteractionEnabled = false

        spinnerView.endRefreshing()
        spinnerView.removeFromSuperview()

        setShadow()
        getData()
    }

    func setShadow() {
        bottomView.layer.shadowOffset = CGSize(width: 3, height: 3)
        bottomView.layer.shadowRadius = 5
        bottomView.layer.shadowOpacity = 0.3
    }

    func getData() {
        spinnerView = JTMaterialSpinner()
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        view.addSubview(spinnerView)
        spinnerView.beginRefreshing()
        var parameters: Parameters = [:]
        if datesRange != nil {
            if datesRange!.count > 1 {
                parameters = ["id": user_id, "startdate": dateFormatter.string(from: datesRange!.first!), "enddate": dateFormatter.string(from: datesRange!.last!)]
            } else {
                parameters = ["id": user_id, "startdate": dateFormatter.string(from: datesRange!.first!), "enddate": dateFormatter.string(from: datesRange!.first!)]
            }
        } else {
            parameters = ["id": user_id, "startdate": dateFormatter.string(from: Date()), "enddate": dateFormatter.string(from: Date())]
        }
        AF.request(Global.baseUrl + "api/getCaldata", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { [self] response in
            self.spinnerView.endRefreshing()
            self.spinnerView.removeFromSuperview()
            if let value = response.value as? [String: AnyObject] {
                self.allIncome = []
                self.allLiability = []
                var incomeTotal = 0.0, liabilityTotal = 0.0
                let payInfos = value["payinfo"] as? [[String: AnyObject]]
                if payInfos!.count > 0 {
                    for i in 0 ... (payInfos!.count) - 1 {
                        let id = payInfos![i]["id"] as! String
                        let categoryid = payInfos![i]["categoryid"] as! String
                        let price = payInfos![i]["price"] as! String
                        let paydate = payInfos![i]["date"] as! String
                        let paytype = payInfos![i]["paytype"] as! String

                        if paytype == "income" {
                            let incomeCell = Income(id: id, categoryid: Int(categoryid)!, price: price, paydate: paydate, paytype: paytype)
                            self.allIncome.append(incomeCell)
                            incomeTotal += Double(price) ?? 0.0
                        } else {
                            let liabilityCell = Liability(id: id, categoryid: Int(categoryid)!, price: price, paydate: paydate, paytype: paytype)
                            self.allLiability.append(liabilityCell)
                            liabilityTotal += Double(price) ?? 0.0
                        }
                    }
                }
                incomeTotalLabel.text = "\(incomeTotal)"
                liabilityTotalLabel.text = "\(liabilityTotal)"
                finalAmountLabel.text = "Inc: $\(incomeTotal) - Lib: $\(liabilityTotal): $\(incomeTotal - liabilityTotal)"
                self.incomeTBHeight.constant = CGFloat(44 * self.allIncome.count)
                self.liabilityTBHeight.constant = CGFloat(44 * self.allLiability.count)
                self.incomeTB.layoutIfNeeded()
                self.liabilityTB.layoutIfNeeded()
                self.incomeTB.updateConstraints()
                self.liabilityTB.updateConstraints()
                self.incomeTB.reloadData()
                self.liabilityTB.reloadData()
            }
        }
    }

    @IBAction func onUserBtn(_: Any) {
        userVC = storyboard?.instantiateViewController(withIdentifier: "userVC") as? UserVC
        userVC.modalPresentationStyle = .fullScreen
        present(userVC, animated: true, completion: nil)
    }

    @IBAction func onHomeBtn(_: Any) {
        homeVC = storyboard?.instantiateViewController(withIdentifier: "homeVC") as? HomeVC
        homeVC.modalPresentationStyle = .fullScreen
        present(homeVC, animated: true, completion: nil)
    }

    @IBAction func onSettingBtn(_: Any) {
        settingVC = storyboard?.instantiateViewController(withIdentifier: "settingVC") as? SettingVC
        settingVC.modalPresentationStyle = .fullScreen
        present(settingVC, animated: true, completion: nil)
    }

    @IBAction func calendarSegmentChangedValue(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            calendarView.scope = .month
            constraintCalendarHeight.constant = 380
        } else {
            calendarView.scope = .week
            constraintCalendarHeight.constant = 130
        }
    }

    @IBAction func btnAddIncomeClicked(_: UIButton) {
        if let incomeVC = storyboard?.instantiateViewController(withIdentifier: "setincomeVC") as? SetIncomeVC {
            incomeVC.modalPresentationStyle = .fullScreen
            present(incomeVC, animated: true, completion: nil)
        }
    }

    @IBAction func btnAddLiabilityClicked(_: UIButton) {
        if let setlibilityVC = storyboard?.instantiateViewController(withIdentifier: "setlibilityVC") as? SetLiabilityVC {
            setlibilityVC.modalPresentationStyle = .fullScreen
            present(setlibilityVC, animated: true, completion: nil)
        }
    }

    private func datesRange(from: Date, to: Date) -> [Date] {
        if from > to { return [Date]() }

        var tempDate = from
        var array = [tempDate]

        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        return array
    }
}

extension CalendarVC: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
        configure(cell: cell, for: date, at: position)
        return cell
    }

    private func configureVisibleCells() {
        calendarView.visibleCells().forEach { cell in
            let date = calendarView.date(for: cell)
            let position = calendarView.monthPosition(for: cell)
            self.configure(cell: cell, for: date!, at: position)
        }
    }

    private func configure(cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
        let cell = (cell as! DateCell)
        cell.circleImageView.isHidden = !gregorian.isDateInToday(date)
        if position == .current {
            var selectionType = SelectionType.none

            if calendarView.selectedDates.contains(date) {
                let previousDate = gregorian.date(byAdding: .day, value: -1, to: date)!
                let nextDate = gregorian.date(byAdding: .day, value: 1, to: date)!
                if calendarView.selectedDates.contains(date) {
                    if calendarView.selectedDates.contains(previousDate), calendarView.selectedDates.contains(nextDate) {
                        selectionType = .middle
                    } else if calendarView.selectedDates.contains(previousDate), calendarView.selectedDates.contains(date) {
                        selectionType = .rightBorder
                    } else if calendarView.selectedDates.contains(nextDate) {
                        selectionType = .leftBorder
                    } else {
                        selectionType = .single
                    }
                }
            } else {
                selectionType = .none
            }
            if selectionType == .none {
                cell.selectionLayer.isHidden = true
                return
            }
            cell.selectionLayer.isHidden = false
            cell.selectionType = selectionType

        } else {
            cell.circleImageView.isHidden = true
            cell.selectionLayer.isHidden = true
        }
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            calendar.select(firstDate)
            getData()
            configureVisibleCells()
            return
        }
        if firstDate != nil, lastDate == nil {
            if date <= firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                calendar.select(firstDate)
                getData()
                configureVisibleCells()
                return
            }

            let range = datesRange(from: firstDate!, to: date)
            lastDate = range.last
            for d in range {
                calendar.select(d)
            }
            datesRange = range
            getData()
            configureVisibleCells()
            return
        }
        if firstDate != nil, lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            lastDate = nil
            firstDate = nil
            datesRange = []

            firstDate = date
            datesRange = [firstDate!]
            calendar.select(firstDate)
            getData()
            configureVisibleCells()
        }
    }

    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at _: FSCalendarMonthPosition) {
        if firstDate != nil, lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            lastDate = nil
            firstDate = nil
            datesRange = []
        }
        if firstDate != nil, date <= firstDate! {
            calendar.deselect(date)
            firstDate = nil
        }
        configureVisibleCells()
    }

    func calendar(_: FSCalendar, appearance _: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        var colors: [UIColor] = []
        if AppDelegate.shared().allIncome.contains(where: { $0.paydate == dateFormatter.string(from: date) }) {
            colors.append(UIColor(named: "majorcolor") ?? .green)
        }
        if AppDelegate.shared().allLiability.contains(where: { $0.paydate == dateFormatter.string(from: date) }) {
            colors.append(UIColor(named: "secondcolor") ?? .blue)
        }
        return colors
    }

    func calendar(_: FSCalendar, appearance _: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        var colors: [UIColor] = []
        if AppDelegate.shared().allIncome.contains(where: { $0.paydate == dateFormatter.string(from: date) }) {
            colors.append(UIColor(named: "majorcolor") ?? .green)
        }
        if AppDelegate.shared().allLiability.contains(where: { $0.paydate == dateFormatter.string(from: date) }) {
            colors.append(UIColor(named: "secondcolor") ?? .blue)
        }
        return colors
    }

    func calendar(_: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var count = 0
        if AppDelegate.shared().allIncome.contains(where: { $0.paydate == dateFormatter.string(from: date) }) {
            count += 1
        }
        if AppDelegate.shared().allLiability.contains(where: { $0.paydate == dateFormatter.string(from: date) }) {
            count += 1
        }
        return count
    }
}

extension CalendarVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if tableView.tag == 200 {
            return allIncome.count
        } else {
            return allLiability.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 200 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! IncomeCell
            let oneIncome = allIncome[indexPath.row]
            let income_title = allIncomeCategory[oneIncome.categoryid].title
            let income_image = allIncomeCategory[oneIncome.categoryid].imageUrl
            cell.priceImg.image = UIImage(named: income_image)
            cell.priceTitle.text = income_title
            cell.priceValue.text = oneIncome.price
            cell.priceDate.text = oneIncome.paydate
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! LiabilityCell
            let oneLiability = allLiability[indexPath.row]
            let liability_title = allLiabilityCategory[oneLiability.categoryid].title
            let income_image = allLiabilityCategory[oneLiability.categoryid].imageUrl
            cell.priceImg.image = UIImage(named: income_image)
            cell.priceTitle.text = liability_title
            cell.priceValue.text = oneLiability.price
            cell.priceDate.text = oneLiability.paydate
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.tag == 200 {
            AppDelegate.shared().sel_payid = allIncome[indexPath.row].id
            updateincomeVC = storyboard?.instantiateViewController(withIdentifier: "updateincomeVC") as? UpdateIncomeVC
            updateincomeVC.modalPresentationStyle = .fullScreen
            present(updateincomeVC, animated: true, completion: nil)
        } else {
            AppDelegate.shared().sel_payid = allLiability[indexPath.row].id
            updateliabilityVC = storyboard?.instantiateViewController(withIdentifier: "updateliabilityVC") as? UpdateLiabilityVC
            updateliabilityVC.modalPresentationStyle = .fullScreen
            present(updateliabilityVC, animated: true, completion: nil)
        }
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 44
    }
}
