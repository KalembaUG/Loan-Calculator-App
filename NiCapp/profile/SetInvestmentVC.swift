// Created 27/01/22

import Alamofire
import iOSDropDown
import JTMaterialSpinner
import UIKit
class SetInvestmentVC: UIViewController {
    @IBOutlet var categoryView: UIView!
    @IBOutlet var priceView: UIView!

    @IBOutlet var categoryDV: DropDown!
    let allInvestCategory = Global.allInvestmentCategory
    var spinnerView = JTMaterialSpinner()
    @IBOutlet var priceTxt: UITextField!
    var user_id = ""
    var price = ""
    var sel_category = 100
    override func viewDidLoad() {
        super.viewDidLoad()
        user_id = UserDefaults.standard.string(forKey: "userID") ?? "1"
        setShadow()
        setCategory()
    }

    func setShadow() {
        priceView.layer.shadowOffset = CGSize(width: 3, height: 3)
        priceView.layer.shadowRadius = 5
        priceView.layer.shadowOpacity = 0.3

        categoryView.layer.shadowOffset = CGSize(width: 3, height: 3)
        categoryView.layer.shadowRadius = 5
        categoryView.layer.shadowOpacity = 0.3
    }

    @IBAction func onBackBtn(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onCancelBtn(_: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onSetBtn(_: Any) {
        price = priceTxt.text!
        if !isValid() {
            return
        }
        view.addSubview(spinnerView)
        spinnerView.frame = CGRect(x: (UIScreen.main.bounds.size.width - 50.0) / 2.0, y: (UIScreen.main.bounds.size.height - 50) / 2, width: 50, height: 50)
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor.orange.cgColor
        spinnerView.beginRefreshing()
        let parameters: Parameters = ["id": user_id, "value": price, "type": sel_category]
        AF.request(Global.baseUrl + "api/setinvestment", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            print(response)
            self.spinnerView.endRefreshing()
            if let value = response.value as? [String: AnyObject] {
                let status = value["status"] as? String
                if status == "ok" {
                    self.view.makeToast("Add Investment Success")
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.view.makeToast("Fail add")
                }
            } else {
                self.view.makeToast("Fail add")
            }
        }
    }

    func setCategory() {
        categoryDV.optionArray = allInvestCategory
        categoryDV.didSelect { _, index, _ in
            self.sel_category = index
            print("\(index)")
        }
    }

    func isValid() -> Bool {
        if price == "" {
            view.makeToast("Input Price")
            return false
        }
        if sel_category == 100 {
            view.makeToast("Select Category")
            return false
        }
        return true
    }
}
