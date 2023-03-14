//
//  DiscloserVC.swift
//  calculator
//
//  Created by bird on 5/11/21.
//

import SimpleCheckbox
import UIKit
class DiscloserVC: UIViewController {
    @IBOutlet var termCheck: Checkbox!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var discloserView: UIView!
    var termVC: TermVC!
    override func viewDidLoad() {
        super.viewDidLoad()
        setShadow()
        termCheck.addTarget(self, action: #selector(checkboxValueChanged(sender:)), for: .valueChanged)
    }

    func setShadow() {
        discloserView.layer.shadowOffset = CGSize(width: 3, height: 3)
        discloserView.layer.shadowRadius = 5
        discloserView.layer.shadowOpacity = 0.3
    }

    @objc func checkboxValueChanged(sender: Checkbox) {
        if sender.isChecked {
            confirmBtn.isEnabled = true
        } else {
            confirmBtn.isEnabled = false
        }
    }

    @IBAction func onConfirmBtn(_: Any) {
        termVC = storyboard?.instantiateViewController(withIdentifier: "termVC") as? TermVC
        termVC.modalPresentationStyle = .fullScreen
        present(termVC, animated: true, completion: nil)
    }
}
