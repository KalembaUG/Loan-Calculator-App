// Created 27/01/22

import Alamofire
import Charts
import JTMaterialSpinner
import UIKit

class HomeVC: UIViewController {
    var seldurationVC: SelDurationVC!
    var setincomeVC: SetIncomeVC!
    var setlibilityVC: SetLiabilityVC!
    var userVC: UserVC!
    var calendarVC: CalendarVC!
    var settingVC: SettingVC!
    var updateincomeVC: UpdateIncomeVC!
    var updateliabilityVC: UpdateLiabilityVC!

    @IBOutlet var chartView: PieChartView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var dateTxt: UILabel!
    @IBOutlet var typeTxt: UILabel!

    @IBOutlet var incomeTB: UITableView!
    @IBOutlet var liabilityTB: UITableView!

    @IBOutlet var incomeTxt: UILabel!
    @IBOutlet var liabilityTxt: UILabel!
    @IBOutlet var remainTxt: UILabel!

    @IBOutlet var incomeTBHeight: NSLayoutConstraint!
    @IBOutlet var liabilityTBHeight: NSLayoutConstraint!

    var first_view = "first"
    var today_string = ""

    var startdate_string = ""
    var enddate_string = ""

    var current_date = Date()
    var start_date = Date()
    var end_date = Date()

    var spinnerView = JTMaterialSpinner()

    let allIncomeCategory = Global.allIncomeCategory
    let allLiabilityCategory = Global.allLiabilityCategory
    let parties = ["Income", "Liability"]
    var prices = [0.0, 0.0]
    var sel_type = 8
    var user_id = ""
    var allIncome = [Income]()
    var allLiability = [Liability]()

    var income_price = 1
    var liability_price = 8

    override func viewDidLoad() {
        super.viewDidLoad()
        typeTxt.layer.masksToBounds = true
        typeTxt.layer.cornerRadius = 10
        // add shadow
        typeTxt.layer.shadowOffset = CGSize(width: 3, height: 3)

        user_id = UserDefaults.standard.string(forKey: "userID") ?? "1"

        incomeTB.delegate = self
        incomeTB.dataSource = self
        incomeTB.register(UINib(nibName: "IncomeCell", bundle: nil), forCellReuseIdentifier: "cell")
        incomeTB.isUserInteractionEnabled = false

        liabilityTB.delegate = self
        liabilityTB.dataSource = self
        liabilityTB.register(UINib(nibName: "LiabilityCell", bundle: nil), forCellReuseIdentifier: "cell")
        liabilityTB.isUserInteractionEnabled = false

        let labelTapGesture = UITapGestureRecognizer(target: self, action: #selector(typeSelecte))
        typeTxt.isUserInteractionEnabled = true
        typeTxt.addGestureRecognizer(labelTapGesture)

        setShadow()
        setDataCount()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_: Bool) {
        super.viewWillAppear(true)
        current_date = Date()
        getData()
    }

    @objc func typeSelecte() {
        seldurationVC = storyboard?.instantiateViewController(withIdentifier: "seldurationVC") as? SelDurationVC
        seldurationVC.modalPresentationStyle = .fullScreen
        present(seldurationVC, animated: true, completion: nil)
    }

    func getData() {
        incomeTB.isUserInteractionEnabled = false
        liabilityTB.isUserInteractionEnabled = false
        view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": user_id, "type": sel_type]
        AF.request(Global.baseUrl + "api/gethomedata", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                self.allIncome = []
                self.allLiability = []
                AppDelegate.shared().allIncome = []
                AppDelegate.shared().allLiability = []

                self.income_price = 0
                self.liability_price = 0

                let payInfos = value["payinfo"] as? [[String: AnyObject]]
                if payInfos!.count > 0 {
                    for i in 0 ... (payInfos!.count) - 1 {
                        let id = payInfos![i]["id"] as! String
                        let categoryid = payInfos![i]["categoryid"] as! String
                        let price = payInfos![i]["price"] as! String
                        let paydate = payInfos![i]["date"] as! String
                        let paytype = payInfos![i]["paytype"] as! String
                        if paytype == "income" {
//                            self.income_price = self.income_price + Int(price)!
                            let incomeCell = Income(id: id, categoryid: Int(categoryid)!, price: price, paydate: paydate, paytype: paytype)
//                            self.allIncome.append(incomeCell)
                            AppDelegate.shared().allIncome.append(incomeCell)
                        } else {
//                            self.liability_price = self.liability_price + Int(price)!
                            let liabilityCell = Liability(id: id, categoryid: Int(categoryid)!, price: price, paydate: paydate, paytype: paytype)
//                            self.allLiability.append(liabilityCell)
                            AppDelegate.shared().allLiability.append(liabilityCell)
                        }
                    }
                }
                self.displayDate()
            }
        }
    }

    func displayDate() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        sel_type = AppDelegate.shared().duration
        if sel_type == 0 {
            startdate_string = formatter.string(from: current_date)
            enddate_string = formatter.string(from: current_date)
            typeTxt.text = "Daily"
            dateTxt.text = startdate_string
        } else if sel_type == 1 {
            let sunday = getSunday(myDate: current_date)
            let saturday = getSaturday(myDate: current_date)
            startdate_string = formatter.string(from: sunday)
            enddate_string = formatter.string(from: saturday)
            dateTxt.text = startdate_string + " ~ " + enddate_string
            typeTxt.text = "Weekly"
        } else if sel_type == 2 {
            let year = Calendar.current.component(.year, from: current_date)
            let month = Calendar.current.component(.month, from: current_date)
            let day = Calendar.current.component(.day, from: current_date)
            if day > 15 {
                let lastday = getLastMonth(myDate: current_date)
                enddate_string = formatter.string(from: lastday)
                formatter.dateFormat = "yyyy-MM" + "-16"
                startdate_string = formatter.string(from: current_date)
                formatter.dateFormat = "yyyy-MM" + "-28"
                let currentdate_string = formatter.string(from: current_date)
                formatter.dateFormat = "yyyy-MM-dd"
                current_date = formatter.date(from: currentdate_string)!
            } else {
                let firstday = getFirstMonth(myDate: current_date)
                current_date = firstday
                startdate_string = formatter.string(from: firstday)
                formatter.dateFormat = "yyyy-MM" + "-15"
                enddate_string = formatter.string(from: current_date)
                formatter.dateFormat = "yyyy-MM" + "-03"
                let currentdate_string = formatter.string(from: current_date)
                formatter.dateFormat = "yyyy-MM-dd"
                current_date = formatter.date(from: currentdate_string)!
            }
            dateTxt.text = startdate_string + " ~ " + enddate_string
            typeTxt.text = "Semi-Monthly"
        } else if sel_type == 3 {
            let firstday = getFirstMonth(myDate: current_date)
            let lastday = getLastMonth(myDate: current_date)
            startdate_string = formatter.string(from: firstday)
            enddate_string = formatter.string(from: lastday)
            dateTxt.text = startdate_string + " ~ " + enddate_string
            print(startdate_string)
            print(enddate_string)
            typeTxt.text = "Monthly"
        } else if sel_type == 4 {
            let year = Calendar.current.component(.year, from: current_date)
            let month = Calendar.current.component(.month, from: current_date)
            if month < 7 {
                startdate_string = "\(year)" + "-01-01"
                enddate_string = "\(year)" + "-06-30"

            } else {
                startdate_string = "\(year)" + "-07-01"
                enddate_string = "\(year)" + "-12-31"
            }
            dateTxt.text = startdate_string + " ~ " + enddate_string
            typeTxt.text = "Semi-Annually"
        } else if sel_type == 5 {
            let year = Calendar.current.component(.year, from: current_date)
            startdate_string = "\(year)" + "-01-01"
            enddate_string = "\(year)" + "-12-31"
            dateTxt.text = startdate_string + " ~ " + enddate_string
            typeTxt.text = "Annually"
        } else {
            let sunday = getSunday(myDate: current_date)
            let saturday = getSaturday(myDate: current_date)
            startdate_string = formatter.string(from: sunday)
            enddate_string = formatter.string(from: saturday)
            dateTxt.text = startdate_string + " ~ " + enddate_string
            typeTxt.text = "Weekly"
        }
        displaydata()
    }

    func getSunday(myDate: Date) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = 1 // Sunday
        let sundayInWeek = cal.date(from: comps)!
        return sundayInWeek
    }

    func getSaturday(myDate: Date) -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents([.weekOfYear, .yearForWeekOfYear], from: myDate)
        comps.weekday = 7 // Monday
        let saturdayInWeek = cal.date(from: comps)!
        return saturdayInWeek
    }

    func getFirstMonth(myDate: Date) -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: myDate)
        let FirstdayInMonth = cal.date(from: comps)!
        return FirstdayInMonth
    }

    func getLastMonth(myDate: Date) -> Date {
        let cal = Calendar.current
        let components = DateComponents(day: 1)
        let startOfNextMonth = cal.nextDate(after: myDate, matching: components, matchingPolicy: .nextTime)!
        return cal.date(byAdding: .day, value: -1, to: startOfNextMonth)!
    }

    func getNextDay(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .day, value: 1, to: myDate)!
    }

    func getPreviousDay(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .day, value: -1, to: myDate)!
    }

    func getNextWeek(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .weekOfYear, value: 1, to: myDate)!
    }

    func getPreviousWeek(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .weekOfYear, value: -1, to: myDate)!
    }

    func getNextSemiMonth(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .day, value: 15, to: myDate)!
    }

    func getPreviousSemiMonth(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .day, value: -15, to: myDate)!
    }

    func getNextMonth(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .month, value: 1, to: myDate)!
    }

    func getPreviousMonth(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .month, value: -1, to: myDate)!
    }

    func getNextSixMonth(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .month, value: 6, to: myDate)!
    }

    func getPreviousSixMonth(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .month, value: -6, to: myDate)!
    }

    func getNextYear(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .year, value: 1, to: myDate)!
    }

    func getPreviousYear(myDate: Date) -> Date {
        let cal = Calendar.current
        return cal.date(byAdding: .year, value: -1, to: myDate)!
    }

    func displaydata() {
        allIncome = []
        allLiability = []
        income_price = 0
        liability_price = 0
        let currentIncome = AppDelegate.shared().allIncome
        let currentLiability = AppDelegate.shared().allLiability
        if currentIncome.count > 0 {
            if typeTxt.text == "Annually" || typeTxt.text == "Semi-Annually" {
                let incomeCellsGroupedByCategory = Dictionary(grouping: currentIncome, by: { $0.categoryid })
                for (key, value) in incomeCellsGroupedByCategory {
                    var categoryPrice = 0
                    for i in 0 ... (value.count) - 1 {
                        let price = value[i].price
                        let paydate = value[i].paydate
                        if paydate >= startdate_string, paydate <= enddate_string {
                            categoryPrice = categoryPrice + Int(price)!
                            income_price = income_price + Int(price)!
                        }
                    }
                    let incomeCell = Income(
                        id: value[0].id,
                        categoryid: value[0].categoryid,
                        price: String(categoryPrice),
                        paydate: value[0].paydate,
                        paytype: value[0].paytype
                    )
                    allIncome.append(incomeCell)
                }
            } else {
                for i in 0 ... (currentIncome.count) - 1 {
                    let id = currentIncome[i].id
                    let categoryid = currentIncome[i].categoryid
                    let price = currentIncome[i].price
                    let paydate = currentIncome[i].paydate
                    let paytype = currentIncome[i].paytype
                    if paydate >= startdate_string, paydate <= enddate_string {
                        income_price = income_price + Int(price)!
                        let incomeCell = Income(id: id, categoryid: categoryid, price: price, paydate: paydate, paytype: paytype)
                        allIncome.append(incomeCell)
                    }
                }
            }
        }

        if currentLiability.count > 0 {
            if typeTxt.text == "Annually" || typeTxt.text == "Semi-Annually" {
                let incomeCellsGroupedByCategory = Dictionary(grouping: currentLiability, by: { $0.categoryid })
                for (key, value) in incomeCellsGroupedByCategory {
                    var categoryPrice = 0
                    for i in 0 ... (value.count) - 1 {
                        let price = value[i].price
                        let paydate = value[i].paydate
                        if paydate >= startdate_string, paydate <= enddate_string {
                            categoryPrice = categoryPrice + Int(price)!
                            liability_price = liability_price + Int(price)!
                        }
                    }
                    let liabilityCell = Liability(
                        id: value[0].id,
                        categoryid: value[0].categoryid,
                        price: String(categoryPrice),
                        paydate: value[0].paydate,
                        paytype: value[0].paytype
                    )
                    allLiability.append(liabilityCell)
                }
            } else {
                for i in 0 ... (currentLiability.count) - 1 {
                    let id = currentLiability[i].id
                    let categoryid = currentLiability[i].categoryid
                    let price = currentLiability[i].price
                    let paydate = currentLiability[i].paydate
                    let paytype = currentLiability[i].paytype
                    if paydate >= startdate_string, paydate <= enddate_string {
                        liability_price = liability_price + Int(price)!
                        let liabilityCell = Liability(id: id, categoryid: categoryid, price: price, paydate: paydate, paytype: paytype)
                        allLiability.append(liabilityCell)
                    }
                }
            }
        }

        incomeTxt.text = String(income_price) + "$"
        liabilityTxt.text = String(liability_price) + "$"
        remainTxt.text = String(income_price - liability_price) + "$"
        setDataCount()
        incomeTBHeight.constant = CGFloat(44 * allIncome.count)
        liabilityTBHeight.constant = CGFloat(44 * allLiability.count)
        incomeTB.layoutIfNeeded()
        liabilityTB.layoutIfNeeded()
        incomeTB.updateConstraints()
        liabilityTB.updateConstraints()
        incomeTB.reloadData()
        liabilityTB.reloadData()
        incomeTB.isUserInteractionEnabled = true
        liabilityTB.isUserInteractionEnabled = true
    }

    func setShadow() {
        bottomView.layer.shadowOffset = CGSize(width: 3, height: 3)
        bottomView.layer.shadowRadius = 5
        bottomView.layer.shadowOpacity = 0.3
    }

    func setDataCount() {
        let total_price = Double(income_price + liability_price)
        if total_price == 0 {
            chartView.holeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        } else {
            chartView.holeColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        }
        if total_price == 0 {
            prices[0] = 1.0
            prices[1] = 0.0
        } else {
            prices[0] = Double(income_price) * 100.0 / total_price
            prices[1] = Double(liability_price) * 100.0 / total_price
        }

        let entries = (0 ..< 2).map { i -> PieChartDataEntry in
            PieChartDataEntry(value: prices[i],
                              label: parties[i],
                              icon: nil)
        }

        let set = PieChartDataSet(entries: entries)
        set.drawIconsEnabled = false
        set.sliceSpace = 2

        set.colors = [UIColor(red: 2 / 255, green: 195 / 255, blue: 154 / 255, alpha: 1)]
            + [UIColor(red: 5 / 255, green: 102 / 255, blue: 141 / 255, alpha: 1)]

        let data = PieChartData(dataSet: set)

        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))

        chartView.data = data

        chartView.highlightValues(nil)
    }

    @IBAction func onNextDateBtn(_: Any) {
        sel_type = AppDelegate.shared().duration
        if sel_type == 0 {
            current_date = getNextDay(myDate: current_date)
        } else if sel_type == 1 {
            current_date = getNextWeek(myDate: current_date)
        } else if sel_type == 2 {
            current_date = getNextSemiMonth(myDate: current_date)
        } else if sel_type == 3 {
            current_date = getNextMonth(myDate: current_date)
        } else if sel_type == 4 {
            current_date = getNextSixMonth(myDate: current_date)
        } else if sel_type == 5 {
            current_date = getNextYear(myDate: current_date)
        } else {
            current_date = getNextWeek(myDate: current_date)
        }
        displayDate()
    }

    @IBAction func onPreviousDateBtn(_: Any) {
        sel_type = AppDelegate.shared().duration
        if sel_type == 0 {
            current_date = getPreviousDay(myDate: current_date)
        } else if sel_type == 1 {
            current_date = getPreviousWeek(myDate: current_date)
        } else if sel_type == 2 {
            current_date = getPreviousSemiMonth(myDate: current_date)
        } else if sel_type == 3 {
            current_date = getPreviousMonth(myDate: current_date)
        } else if sel_type == 4 {
            current_date = getPreviousSixMonth(myDate: current_date)
        } else if sel_type == 5 {
            current_date = getPreviousYear(myDate: current_date)
        } else {
            current_date = getPreviousWeek(myDate: current_date)
        }
        displayDate()
    }

    @IBAction func onSummaryBtn(_: Any) {
        seldurationVC = storyboard?.instantiateViewController(withIdentifier: "seldurationVC") as? SelDurationVC
        seldurationVC.modalPresentationStyle = .fullScreen
        present(seldurationVC, animated: true, completion: nil)
    }

    @IBAction func onSetIncomeBtn(_: Any) {
        setincomeVC = storyboard?.instantiateViewController(withIdentifier: "setincomeVC") as? SetIncomeVC
        setincomeVC.modalPresentationStyle = .fullScreen
        present(setincomeVC, animated: true, completion: nil)
    }

    @IBAction func onSetLiabilityBtn(_: Any) {
        setlibilityVC = storyboard?.instantiateViewController(withIdentifier: "setlibilityVC") as? SetLiabilityVC
        setlibilityVC.modalPresentationStyle = .fullScreen
        present(setlibilityVC, animated: true, completion: nil)
    }

    @IBAction func onUserBtn(_: Any) {
        userVC = storyboard?.instantiateViewController(withIdentifier: "userVC") as? UserVC
        userVC.modalPresentationStyle = .fullScreen
        present(userVC, animated: true, completion: nil)
    }

    @IBAction func onCalendarBtn(_: Any) {
        calendarVC = storyboard?.instantiateViewController(withIdentifier: "calendarVC") as? CalendarVC
        calendarVC.modalPresentationStyle = .fullScreen
        present(calendarVC, animated: true, completion: nil)
    }

    @IBAction func onSettingBtn(_: Any) {
        settingVC = storyboard?.instantiateViewController(withIdentifier: "settingVC") as? SettingVC
        settingVC.modalPresentationStyle = .fullScreen
        present(settingVC, animated: true, completion: nil)
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection _: Int) -> Int {
        if tableView.tag == 1000 {
            return allIncome.count
        } else {
            return allLiability.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView.tag == 1000 {
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
        if tableView.tag == 1000 {
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
