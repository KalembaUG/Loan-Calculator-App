// Created 22/08/21

import Alamofire
import iOSDropDown
import JTMaterialSpinner
import Toast_Swift
import UIKit
class SetLiabilityVC: UIViewController {
    @IBOutlet var noteView: UIView!
    @IBOutlet var repeatView: UIView!
    @IBOutlet var categoryView: UIView!
    @IBOutlet var priceView: UIView!
    @IBOutlet var dateView: UIView!
    @IBOutlet var endDateView: UIView!

    @IBOutlet var noteTxt: UITextField!
    @IBOutlet var repeatDV: DropDown!
    @IBOutlet var liabilityDV: DropDown!
    @IBOutlet var priceTxt: UITextField!
    @IBOutlet var dateTxt: UITextField!
    @IBOutlet var enddateTxt: UITextField!

    var spinnerView = JTMaterialSpinner()
    var price = ""
    var note = ""
    var date_string = "2021-06-08"
    var enddate_string = ""
    var allLiabilityString = [String]()
    var allRepeatCategory = Global.allRepeatCategory
    var allLiabilityCategory = Global.allLiabilityCategory
    var sel_liability = 100
    var sel_repeat = 100
    var user_id = "0"
    let formatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        user_id = UserDefaults.standard.string(forKey: "userID") ?? "1"
        formatter.dateFormat = "yyyy-MM-dd"
        dateTxt.text = formatter.string(from: Date())
        dateTxt.setInputViewDatePicker(target: self, selector: #selector(tapDone))
        enddateTxt.setInputViewDatePicker(target: self, selector: #selector(tapEndDone))
        dateTxt.isEnabled = false
        // enddateTxt.isEnabled = false
        endDateView.isHidden = true
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
        endDateView.layer.shadowOffset = CGSize(width: 3, height: 3)
        endDateView.layer.shadowRadius = 5
        endDateView.layer.shadowOpacity = 0.3
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
        let parameters: Parameters = ["id": user_id, "value": price, "categoryid": sel_liability, "repeatid": sel_repeat, "note": note, "startdate": date_string, "enddate": enddate_string]
        AF.request(Global.baseUrl + "api/addliability", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["status"] as? String
                if status == "ok" {
                    self.view.makeToast("Liability added successfully")
                    self.priceTxt.text = ""
                    self.noteTxt.text = ""
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.view.makeToast("Fail add")
                }
            } else {
                self.view.makeToast("Fail add")
            }
        }
    }

    func setDropdownData() {
        for i in 0 ... (allLiabilityCategory.count) - 1 {
            let name = allLiabilityCategory[i].title
            allLiabilityString.append(name)
        }
        setCategory()
    }

    func setCategory() {
        liabilityDV.optionArray = allLiabilityString
        liabilityDV.didSelect { _, index, _ in
            self.sel_liability = index
        }
        repeatDV.optionArray = allRepeatCategory
        repeatDV.didSelect { _, index, _ in
            self.sel_repeat = index
            self.dateTxt.isEnabled = true
            self.endDateView.isHidden = false
            // self.enddateTxt.isEnabled = true
            if index == 0 {
                // hide end date
                self.endDateView.isHidden = true
                // self.enddateTxt.isEnabled = false
            }
        }
    }

    func isValid() -> Bool {
        if date_string == "" {
            view.makeToast("Input Start Date")
            return false
        }
        if price == "" {
            view.makeToast("Input Price")
            return false
        }
        if sel_liability == 100 {
            view.makeToast("Please select liability type")
            return false
        }
        if sel_repeat == 100 {
            view.makeToast("Select Repeat")
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
