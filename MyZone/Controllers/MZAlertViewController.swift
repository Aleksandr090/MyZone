//
//  MZAlertViewController.swift
//  MyZone
//

import UIKit


@objc public protocol MZAlertViewDelegate {
    @objc optional func didSelectDate( date : Date?)
    @objc optional func didSelectPhoneNumber( phone : String?)
    @objc optional func didSendAudio()
    @objc optional func didReport(itemIndex: Int, type: String)
    @objc optional func deleteMyPost()
}


class MZAlertViewController: BaseAlertViewController {
    
    enum AlertType {
        case login
        case logout
        case phone
        case date
        case deleteAccount
        case sendAudioMessage
        case report
        case deletePost
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var alertTextField: MZTextField!
    @IBOutlet weak var alertTextFieldContainer: UIView!
    @IBOutlet weak var firstButton: MZButton!
    @IBOutlet weak var secondTButton: MZButton!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var reportTblView: UITableView!
    
    var delegate: MZAlertViewDelegate?
    let dateTimePicker = UIDatePicker()
    var phoneNumberSave: ((String) -> Void)?
    
    var reports = ["Scam", "Nudity", "Violence", "Illegal", "Others"]
    var itemIndex = 0
    var selectedReportIndex = 0
    var alertType = AlertType.login
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
//        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupUI()
    }
    
    func setupUI() {
        alertTextFieldContainer.isHidden = true
        pickerContainerView.isHidden = true
        titleLabel.isHidden = true
        reportTblView.isHidden = true
        
        switch alertType {
        case .login:
            titleLabel.isHidden = false
        case .logout:
            titleLabel.isHidden = false
            titleLabel.text = "Are you sure you want to logout of this app?"
            firstButton.setTitle("No", for: .normal)
            secondTButton.setTitle("Yes", for: .normal)
        case .phone:
            alertTextFieldContainer.isHidden = false
            alertTextField.keyboardType = .phonePad
            alertTextField.borderColorValue = .lightGray
            firstButton.setTitle("Cancel", for: .normal)
            secondTButton.setTitle("Done", for: .normal)
        case .date:
            titleLabel.isHidden = false
            titleLabel.text = "Select Date and Time"
            firstButton.setTitle("Cancel", for: .normal)
            secondTButton.setTitle("Ok", for: .normal)
            configureDatePicker()
        case .deleteAccount:
            titleLabel.isHidden = false
            titleLabel.text = "Are you sure you want to delete your account?"
            firstButton.setTitle("No", for: .normal)
            secondTButton.setTitle("Yes", for: .normal)
        case .sendAudioMessage:
            titleLabel.isHidden = false
            titleLabel.text = "Do you want to send audio message?"
            firstButton.setTitle("No", for: .normal)
            secondTButton.setTitle("Yes", for: .normal)
        case .report:
            titleLabel.isHidden = false
            reportTblView.isHidden = false
            titleLabel.text = "Are you sure you want to report this post?"
            firstButton.setTitle("Cancel", for: .normal)
            firstButton.backgroundColor = .lightGray
            secondTButton.setTitle("Report", for: .normal)
        case .deletePost:
            titleLabel.isHidden = false
            titleLabel.text = "Are you sure you want to delete this post?"
            firstButton.setTitle("No", for: .normal)
            secondTButton.setTitle("Yes", for: .normal)
        }
    }
    
    func configureDatePicker() {
        pickerContainerView.isHidden = false
        dateTimePicker.datePickerMode = .dateAndTime        
        dateTimePicker.frame = CGRect(x: 0, y: 0, width: 200, height: self.pickerContainerView.frame.size.height)
        self.pickerContainerView.addSubview(dateTimePicker)
    }
    
    @IBAction func firstAction (_ sender:UIButton) { // Cancel
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func secondAction (_ sender:UIButton) {
        self.dismiss(animated: true) { [self] in
            switch self.alertType {
            case .login: // Login
                MZUtilManager.openLoginViewController()
            case .logout: // Log-out
                MZUtilManager.performUserLogout()
            case .phone:
                if let phoneNumber = self.alertTextField.text, !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty {
                    //self.phoneNumberSave?(phoneNumber.trimmingCharacters(in: .whitespaces))
                    self.delegate?.didSelectPhoneNumber!(phone: phoneNumber.trimmingCharacters(in: .whitespaces))
                    self.dismiss(animated: true, completion: nil)
                }
            case .date:
                self.delegate?.didSelectDate!(date: self.dateTimePicker.date)
                //self.dismiss(animated: true, completion: nil)
            case .deleteAccount:
                MZUtilManager.openDeleteUserAccount()
            case .sendAudioMessage:
                self.delegate?.didSendAudio!()
                self.dismiss(animated: true)
            case .report:
                self.delegate?.didReport!(itemIndex: itemIndex, type: reports[selectedReportIndex])
            case .deletePost:
                self.delegate?.deleteMyPost!()
            }
        }
    }
}

extension MZAlertViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportCell") as! ReportCell
        cell.configure(reports[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedReportIndex = indexPath.row
    }
}

class ReportCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet var imgCheck: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        imgCheck.image = selected ? UIImage(named: "languageRight") : nil
    }
    
    func configure(_ name: String) {
        lblName.text = name
    }
}
