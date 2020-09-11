//
//  NamePopOverVC.swift
//  FirstProject
//
//  Created by AtillaOzder on 10.06.2017.
//  Copyright © 2017 AtillaOzder. All rights reserved.
//

import UIKit
import RxSwift

final class SendButton: UIButton, Roundable, Gradientable {}
final class PopView: SpringView, Roundable {}

final class NamePopOverVC: UIViewController, ErrorHandling {
    
    // MARK: - Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var popUpView: PopView!
    @IBOutlet weak var sendButton: SendButton!
    @IBOutlet weak var rootStackView: UIStackView!
    
    var topConstant: CGFloat = 0
    
    fileprivate var currentPerson: Person?
    var personHolder: Person {
        get { return self.personHolder }
        set { currentPerson = newValue }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMasterTabBarVC" {
            if let tabBarVC = segue.destination as? MasterTabBarVC {
                tabBarVC.personHolder = currentPerson!
            }
        }
    }
    
    // MARK: - View Methods
    
    fileprivate func setupViews() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // Setup Pop View
        popUpView.backgroundColor = UIColor.white
        popUpView.setCornersRounded(withCornerRadius: 15.0)
        
        topConstant = (self.view.frame.height / 2) - (popUpView.frame.height / 2) - 24 // - DefaultStatusBarFrameHeight
        
        guard currentPerson != nil else { return }
        
        if !(currentPerson!.isNameChanged) && currentPerson!.age >= 18 {
            ageTextField.text = currentPerson!.age.description
            ageTextField.isUserInteractionEnabled = false
        } else if (currentPerson!.age <= 0 && currentPerson!.isNameChanged) {
            nameTextField.text = currentPerson?.username
            nameTextField.isUserInteractionEnabled = false
        }
        
        // Setup Buttons
        
        sendButton.isEnabled = false
        sendButton.setCornersRounded(withCornerRadius: 5.0)
        sendButton.backgroundColor = UIColor.lightGray
        
        // Setup TextFields
        
        addImage(toTextField: nameTextField, image: #imageLiteral(resourceName: "Username").withRenderingMode(.alwaysTemplate))
        addImage(toTextField: ageTextField, image: #imageLiteral(resourceName: "Birthday").withRenderingMode(.alwaysTemplate))
        ageTextField.keyboardType = .numberPad
    }
    
    fileprivate func addImage(toTextField tf: UITextField, image: UIImage) {
        tf.textColor = .black
        tf.delegate = self
        tf.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
        
        tf.borderStyle = .roundedRect
        tf.leftViewMode = .always
        
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width + 10, height: image.size.height)
        imageView.contentMode = .center
        imageView.tintColor = .darkGray
        tf.leftView = imageView
    }
    
    // MARK: - Arrange PopUpView Top Constant with Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        if popUpView.frame.origin.y >= topConstant {
            guard let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
                else { return }
            if keyboardSize.height < topConstant {
                popUpView.y -= keyboardSize.height
            } else {
                popUpView.y -= topConstant
            }
            
            popUpView.animateTo()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if popUpView.frame.origin.y < topConstant {
            popUpView.center = self.view.center
            popUpView.animateTo()
        }
    }
    
    
    // MARK: - Action Methods
    
    @IBAction func sendTapped(_ sender: UIButton) {
        
        let person = Person()
        if let username = self.nameTextField.text, let age = self.ageTextField.text {
            person.username = username
            person.age = Int(age)!
            person.isOnline = true
            person.isNameChanged = true
        }
        
        _ = NetworkManager.sharedManager.patchRequest(person: person).subscribe(onNext: { result in
            
        }, onError: { error in
            
            let responseError: NSError = error as NSError
            if responseError.code == 400 {
                self.errorLabel.text = "Üzgünüz, bu anonim adı daha önce kullanılmış.\nLütfen başka bir anonim adı tercih ediniz."
                self.sendButton.isEnabled = false
                self.sendButton.backgroundColor = .lightGray
            } else {
                self.handle(error: error)
            }
            
        }, onCompleted: {
            
            self.currentPerson?.username = person.username
            self.currentPerson?.age = person.age
            self.currentPerson?.isNameChanged = person.isNameChanged
            self.currentPerson?.isOnline = person.isOnline

            self.performSegue(withIdentifier: "toMasterTabBarVC", sender: self)
            
        }, onDisposed: { })
    }
    
    // MARK: - Validation (Observer Text Field)
    
    func textFieldDidChange(textField: UITextField) {
        
        let nameValidation: Observable<Bool> = nameTextField.rx.text.orEmpty
            .map { username in
                
                if !username.isEmpty {
                    
                    do {
                        let regex = try NSRegularExpression(pattern: "^[a-zA-ZğşüöçıĞŞÜÖÇİ0-9]{4,15}$", options: .caseInsensitive)
                        
                        if regex.firstMatch(in: username, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: username.utf16.count)) != nil {
                            self.errorLabel.text = ""
                            return true
                        } else {
                            if (username.utf16.count > 15 || username.utf16.count < 4) {
                                self.errorLabel.text = "Anonim adın 4 ile 15 karakter arasında olmalı"
                            } else {
                                self.errorLabel.text = "Anonim adın özel karakter içermemeli"
                            }
                        }
                    } catch {
                        self.errorLabel.text = "Hay aksi, bir şeyler ters gitti. \nLütfen tekrar deneyin"
                        return false
                    }
                }
                return false
            }
            .shareReplay(1)
        
        let ageValidation: Observable<Bool> = ageTextField.rx.text.orEmpty
            .map { age in
                
                if !age.isEmpty {
                    
                    if age.characters.count == 2 {
                        
                        guard let ageOfPerson = Int(age) else { return false }
                        
                        if ageOfPerson >= 18 {
                            self.errorLabel.text = ""
                            return true
                        } else {
                            self.errorLabel.text = "Yaşın 18 den büyük olmalı"
                            return false
                        }
                        
                    } else {
                        self.errorLabel.text = "Yaşın 18 den büyük olmalı"
                        return false
                    }
                }
                return false
            }
            .shareReplay(1)
        
        let enableButton = Observable.combineLatest(nameValidation, ageValidation) { (name: Bool, age: Bool) in
            return name && age
        }
        
        enableButton
            .bind(to: sendButton.rx.isEnabled)
            .disposed(by: AppDelegate.disposeBag)
        
        if (sendButton.isEnabled) {
            sendButton.backgroundColor = CustomColors.skyBlue.value
        } else {
            sendButton.backgroundColor = UIColor.lightGray
        }
    }
}

// MARK: - TextField Delegate

extension NamePopOverVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.isEqual(nameTextField) {
            
            guard let text = nameTextField.text else { return true }
            
            if (range.length + range.location > text.characters.count) {
                return false
            }
            
            let newLength = text.characters.count + string.characters.count - range.length
            
            return newLength <= 25
            
        } else if textField.isEqual(ageTextField) {
            
            guard let text = ageTextField.text else { return true }
            
            if (range.length + range.location > text.characters.count) {
                return false
            }
            
            let newLength = text.characters.count + string.characters.count - range.length
            
            return newLength <= 2
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
