// Created 22/08/21

import Alamofire
import iOSDropDown
import JTMaterialSpinner
import Toast_Swift
import UIKit
class SetIncomeVC: UIViewController {
    @IBOutlet var repeatView: UIView!
    @IBOutlet var noteView: UIView!
    @IBOutlet var categoryView: UIView!
    @IBOutlet var priceView: UIView!
    @IBOutlet var dateView: UIView!
    @IBOutlet var enddateView: UIView!
    @IBOutlet var noteTxt: UITextField!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var IncomeDV: DropDown!
    @IBOutlet var repeatDV: DropDown!
    @IBOutlet var dateTxt: UITextField!
    @IBOutlet var enddateTxt: UITextField!

    var spinnerView = JTMaterialSpinner()
    var price = ""
    var note = ""
    var date_string = "2021-06-08"
    var enddate_string = ""
    var allIncomeString = [String]()
    var allRepeatCategory = Global.allRepeatCategory
    var allIncomeCategory = Global.allIncomeCategory
    var sel_income = 100
    var sel_repeat = 100
    var user_id = "0"
    let formatter = DateFormatter()
//    let datePicker = UIDatePicker()
    override func viewDidLoad() {
        super.viewDidLoad()
        user_id = UserDefaults.standard.string(forKey: "userID") ?? "1"
        formatter.dateFormat = "yyyy-MM-dd"
//        dateTxt.text = formatter.string(from: Date())
        dateTxt.setInputViewDatePicker(target: self, selector: #selector(tapDone))
        enddateTxt.setInputViewDatePicker(target: self, selector: #selector(tapEndDone))
        dateTxt.isEnabled = false
        // enddateTxt.isEnabled = false
        enddateView.isHidden = true
        setShadow()
        setDropdownData()
    }

    func setShadow() {
        repeatView.layer.shadowOffset = CGSize(width: 3, height: 3)
        repeatView.layer.shadowRadius = 5
        repeatView.layer.shadowOpacity = 0.3
        noteView.layer.shadowOffset = CGSize(width: 3, height: 3)
        noteView.layer.shadowRadius = 5
        noteView.layer.shadowOpacity = 0.3
        categoryView.layer.shadowOffset = CGSize(width: 3, height: 3)
        categoryView.layer.shadowRadius = 5
        categoryView.layer.shadowOpacity = 0.3
        priceView.layer.shadowOffset = CGSize(width: 3, height: 3)
        priceView.layer.shadowRadius = 5
        priceView.layer.shadowOpacity = 0.3
        dateView.layer.shadowOffset = CGSize(width: 3, height: 3)
        dateView.layer.shadowRadius = 5
        dateView.layer.shadowOpacity = 0.3
        enddateView.layer.shadowOffset = CGSize(width: 3, height: 3)
        enddateView.layer.shadowRadius = 5
        enddateView.layer.shadowOpacity = 0.3
    }

    @objc func tapDone() {
        if let datePicker = dateTxt.inputView as? UIDatePicker {
            dateTxt.text = formatter.string(from: datePicker.date)
        }
        dateTxt.resignFirstResponder()
    }

    @objc func tapEndDone() {
        if let datePicker = enddateTxt.inputView as? UIDatePicker {
            enddateTxt.text = formatter.string(from: datePicker.date)
        }
        enddateTxt.resignFirstResponder()
    }

    @IBAction func onBackBtn(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onCancelBtn(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSetBtn(_: Any) {
        price = priceTxt.text!
        note = noteTxt.text!
        date_string = dateTxt.text!
        enddate_string = enddateTxt.text!
        if !isValid() {
            return
        }
        view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": user_id, "value": price, "categoryid": sel_income, "repeatid": sel_repeat, "note": note, "startdate": date_string, "enddate": enddate_string]
        AF.request(Global.baseUrl + "api/addincome", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["status"] as? String
                if status == "ok" {
                    self.view.makeToast("Add income Success")
                    self.dismiss(animated: true, completion: nil)
                    self.priceTxt.text = ""
                    self.noteTxt.text = ""
                } else {
                    self.view.makeToast("Fail add")
                }
            } else {
                self.view.makeToast("Fail add")
            }
        }
    }

    func setDropdownData() {
        for i in 0 ... (allIncomeCategory.count) - 1 {
            let name = allIncomeCategory[i].title
            allIncomeString.append(name)
        }
        setCategory()
    }

    func setCategory() {
        IncomeDV.optionArray = allIncomeString
        IncomeDV.didSelect { _, index, _ in
            self.sel_income = index
            print("\(index)")
        }
        repeatDV.optionArray = allRepeatCategory
        repeatDV.didSelect { _, index, _ in
            self.sel_repeat = index
            print("\(index)")
            self.dateTxt.isEnabled = true
            // self.enddateTxt.isEnabled = true
            self.enddateView.isHidden = false
            if index == 0 {
                // self.enddateTxt.isEnabled = false
                self.enddateView.isHidden = true
            }
        }
    }

    func isValid() -> Bool {
        if date_string == "" {
            view.makeToast("Please select date")
            return false
        }
        if price == "" {
            view.makeToast("Please enter price")
            return false
        }
        if sel_income == 100 {
            view.makeToast("Please select income type")
            return false
        }
        if sel_repeat == 100 {
            view.makeToast("Please select repeat type")
            return false
        } else {
            if sel_repeat != 0 {
                if enddate_string == "" {
                    view.makeToast("Input End Date")
                    return false
                }
            }
        }
        return true
    }
}
