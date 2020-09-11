//
//  SettingsTableVC.swift
//  FirstProject
//
//  Created by AtillaOzder on 21.03.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit
import SafariServices
import MessageUI

final class GetPlusButton: UIButton, Shadowable, Roundable {}

final class SettingsTableVC: UITableViewController, AlertHandling, ErrorHandling {
    
    // MARK: - Properties
    
    @IBOutlet weak var genderChoiceCell: UITableViewCell!
    @IBOutlet weak var switchStatus: UISwitch!
    @IBOutlet weak var getPlusBtn: GetPlusButton!
    
    fileprivate var splashVC: SplashVC!
    let sectionTitles: [String] = ["AYARLAR", "YASAL", "DESTEK", "", ""]
    var versionFooterView: UIView!
    
    weak var personDelegate: PersonDelegate?
    fileprivate var currentPerson: Person?
    var personHolder: Person {
        get { return currentPerson! }
        set { currentPerson = newValue }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        controlCurrentPersonChoice()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChoiceVC" {
            if let choiceVC = segue.destination as? ChoiceTableVC {
                choiceVC.personHolder = self.currentPerson!
                choiceVC.personDelegate = self
            }
        }
    }
    
    // MARK: - View Methods
    
    private func setupViews() {
        splashVC = self.storyboard?.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        
        // Setup Switch Status
        switchStatus.onTintColor = CustomColors.flatGreen.value
        if let isOnline = currentPerson?.isOnline {
            if isOnline {
                switchStatus.setOn(true, animated: false)
            }
            else {
                switchStatus.setOn(false, animated: false)
            }
        }
        
        // Setup Plus Button
        
        getPlusBtn.setCornersRounded(withCornerRadius: 7.0)
        getPlusBtn.addShadow()
        
        guard let imageView = getPlusBtn.imageView else { return }
        imageView.backgroundColor = UIColor.white
        
        setupVersionFooterView()
    }
    
    private func setupVersionFooterView() {
        // Footer View
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 100)
        versionFooterView = UIView(frame: frame)
        
        // Setup Footer Image
        let width = versionFooterView.frame.width / 2
        let height = versionFooterView.frame.height - 50
        let imageFrame = CGRect(x: 0, y: 0, width: width, height: height)
        let footerImage = UIImageView(frame: imageFrame)
        
        footerImage.image = #imageLiteral(resourceName: "Logo").withRenderingMode(.alwaysOriginal)
        footerImage.contentMode = .center
        footerImage.center = versionFooterView.center
        versionFooterView.addSubview(footerImage)
        
        // Setup Footer Label
        let version: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        let versionLbl = UILabel()
        versionLbl.text = "Versiyon \(version)"
        versionLbl.textAlignment = .center
        versionLbl.font = UIFont.preferredCustomFont(withSize: 15.0, customFont: .normal)
        versionLbl.textColor = UIColor.black
        versionLbl.translatesAutoresizingMaskIntoConstraints = false
        
        versionFooterView.addSubview(versionLbl)
        
        // Set Layout Constraints for Label
        versionLbl.centerXAnchor.constraint(equalTo: versionFooterView.centerXAnchor).isActive = true
        versionLbl.heightAnchor.constraint(greaterThanOrEqualTo: versionFooterView.heightAnchor, multiplier: 1.0, constant: 12).isActive = true
        versionLbl.topAnchor.constraint(equalTo: footerImage.topAnchor, constant: 8.0).isActive = true
    }
    
    // MARK: - Helpers

    private func controlCurrentPersonChoice() {
        guard currentPerson != nil else { return }
        guard let detailLbl = genderChoiceCell.detailTextLabel else { return }
        
        switch currentPerson!.choice  {
        case "female":
            detailLbl.text = "Kadınlar"
        case "male":
            detailLbl.text = "Erkekler"
        default:
            detailLbl.text = "Kadınlar ve Erkekler"
        }
        
        guard let text = detailLbl.text else { return }
        AppDelegate.userDefaults.setChoice(value: text)
    }
    
    // MARK: - Action Methods
    
    @IBAction func getPlusBtnTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: "toPlusPopOverVC", sender: self)
    }
    
    @IBAction func switchStatusTapped(_ sender: UISwitch) {
        
        if switchStatus.isOn { personHolder.isOnline = true }
        else { personHolder.isOnline = false }
        
        _ = NetworkManager.sharedManager.patchRequest(person: personHolder).subscribe(onNext: { result in
            
        }, onError: { error in
            
            self.handle(error: error)
            
            let responseError: NSError = error as NSError
            if responseError.code != 401 {
                if self.switchStatus.isOn { self.switchStatus.setOn(false, animated: true) }
                else { self.switchStatus.setOn(true, animated: true) }
            }
            
        }, onCompleted: {
            
            self.personDelegate?.didUpdate(currentPerson: self.personHolder, fromVC: self)
            
        }, onDisposed: { })
    }
    
    fileprivate func logOutTapped() {
        
        let logOutAction = UIAlertAction(title: "Çıkış Yap", style: .destructive) { (alertAction) in
            AppDelegate.loginManager.logOut()
            self.present(self.splashVC, animated: false, completion: nil)
        }
        showActionSheet(withActions: [logOutAction])
    }
    
    fileprivate func deleteAccountTapped() {
        
        let deleteAction = UIAlertAction(title: "Sil", style: .default) { (alertAction) in
            
            self.personHolder.isOnline = false
            self.personHolder.isActive = false
            
            _ = NetworkManager.sharedManager.patchRequest(person: self.personHolder).subscribe(onNext: { result in
                
            }, onError: { error in
                
                self.handle(error: error)
                self.personHolder.isOnline = true
                self.personHolder.isActive = true
                
            }, onCompleted: {
                
                AppDelegate.loginManager.logOut()
                self.present(self.splashVC, animated: true, completion: nil)
                
            }, onDisposed: { })
        }
        
        showAlert(title: "Uyarı!",
                  message: "Hesabını silmek istediğine emin misin? 30 gün içinde geri dönebilirsin!",
                  withActions: [deleteAction],
                  cancelTitle: "İptal")
    }
    
    fileprivate func supportTapped() {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients(["support@FirstProject.com"])

        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeVC, animated: true, completion: nil)
        } else {
            showAlert(title: "Hata",
                      message: "E-mail gönderimi sırasında bir hata oluştu. Lütfen e-mail ayarlarını gözden geçirip tekrar deneyiniz.",
                      withActions: nil,
                      cancelTitle: "Tamam")
        }
    }
}


// MARK: - Table View Data Source

extension SettingsTableVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section]
    }
}

// MARK: - Table View Delegate

extension SettingsTableVC {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 { return (100 - versionFooterView.frame.height) }
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 { return versionFooterView.frame.height }
        return 16.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 3 { return versionFooterView }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath == [0, 0] { return nil }
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        cell.selectionStyle = .gray
        var destinationURL: String? = nil
        
        switch indexPath {
        case [1, 0]:
            destinationURL = NetworkManager.privacyURL
        case [1, 1]:
            destinationURL = NetworkManager.termsURL
        case [1, 2]:
            destinationURL = NetworkManager.licencesURL
        case [2, 0]:
            supportTapped()
        case [3, 0]:
            logOutTapped()
        case [4, 0]:
            deleteAccountTapped()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        if (destinationURL != nil) {
            let safariVC = SFSafariViewController(url: URL(string: destinationURL!)!)
            self.present(safariVC, animated: true, completion: nil)
        }
    }
}

// MARK: - Person Delegate

extension SettingsTableVC: PersonDelegate {
    func didUpdate(currentPerson person: Person, fromVC viewController: UIViewController) {
        self.personHolder = person
        personDelegate?.didUpdate(currentPerson: person, fromVC: self)
    }
}

// MARK: MFMailComposeViewControllerDelegate

extension SettingsTableVC: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
