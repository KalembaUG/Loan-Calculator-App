// Created 12/05/21

import UIKit

class MortgageVC: UIViewController {
    @IBOutlet var loanView: UIView!
    @IBOutlet var RateView: UIView!
    @IBOutlet var amountView: UIView!
    @IBOutlet var topView: UIView!

    @IBOutlet var amountTxt: UITextField!
    @IBOutlet var rateTxt: UITextField!
    @IBOutlet var periodTxt: UITextField!

    @IBOutlet var monthlyTxt: UILabel!
    @IBOutlet var totalTxt: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        setShadow()
    }

    func setShadow() {
        topView.layer.shadowOffset = CGSize(width: 3, height: 3)
        topView.layer.shadowRadius = 5
        topView.layer.shadowOpacity = 0.3

        loanView.layer.shadowOffset = CGSize(width: 3, height: 3)
        loanView.layer.shadowRadius = 5
        loanView.layer.shadowOpacity = 0.3
        RateView.layer.shadowOffset = CGSize(width: 3, height: 3)
        RateView.layer.shadowRadius = 5
        RateView.layer.shadowOpacity = 0.3
        amountView.layer.shadowOffset = CGSize(width: 3, height: 3)
        amountView.layer.shadowRadius = 5
        amountView.layer.shadowOpacity = 0.3
    }

    @IBAction func amountChange(_: Any) {
        cal_Mortgage()
    }

    @IBAction func rateChange(_: Any) {
        cal_Mortgage()
    }

    @IBAction func periodChange(_: Any) {
        cal_Mortgage()
    }

    func cal_Mortgage() {
        if amountTxt.text! == "" {
            totalTxt.text = "0"
            monthlyTxt.text = "0"
            return
        }
        if periodTxt.text! == "" {
            totalTxt.text = "0"
            monthlyTxt.text = "0"
            return
        }
        if rateTxt.text! == "" {
            totalTxt.text = "0"
            monthlyTxt.text = "0"
            return
        }
        let amount = Double(amountTxt.text!) ?? 0.0
        let rate = Double(rateTxt.text!) ?? 0.0
        let period = Double(periodTxt.text!) ?? 0.0
        let interst_rate = rate / 1200.0
        let total_month = period * 12.0
        let value_c = pow(interst_rate + 1, total_month)
        let value_monthly = amount * (interst_rate * value_c) / (value_c - 1)
        let month_price = Double(round(10 * value_monthly) / 10)
        let total_price = Double(round(10 * value_monthly * total_month) / 10)
        totalTxt.text = "\(total_price)"
        monthlyTxt.text = "\(month_price)"
    }

    @IBAction func onBackBtn(_: Any) {
        dismiss(animated: true, completion: nil)
    }
}
