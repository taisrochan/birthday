//
//  BirthdayDataViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 13/07/23.
//

import UIKit

protocol BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, birthday: String)
}

class BirthdayDataViewController: UIViewController  {
    @IBOutlet weak var birthdayPerson: UITextField!
    @IBOutlet weak var birthdayDate: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    let datePicker = UIDatePicker()
    var delegate: BirthdayDataViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        birthdayPerson.addTarget(self,
                                 action: #selector(textFieldDidChange(_:)),
                                 for: .editingChanged)
        birthdayDate.addTarget(self,
                               action: #selector(textFieldDidChange(_:)),
                               for: .editingChanged)
        birthdayDate.clearButtonMode = .always
        
        createDatePicker()
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(closeKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    @objc
    func closeKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    func textFieldDidChange(_ textField: UITextField) {
        verifyTxt()
    }
    
    func verifyTxt() {
        let person = birthdayPerson.text ?? ""
        let birthday = birthdayDate.text ?? ""
        if person.isEmpty || birthday.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let name = birthdayPerson.text ?? ""
        let birthday = birthdayDate.text ?? ""
        delegate?.passBirthdayInfo(name: name, birthday: birthday)
                
        navigationController?.popViewController(animated: true)
    }
    
    func createToolBar() -> UIToolbar {
        let toolBar = UIToolbar ()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneButton], animated: true)
        
        return toolBar
        
    }
    
    func createDatePicker() {
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
       
        birthdayDate.inputView = datePicker
        birthdayDate.inputAccessoryView = createToolBar()
    }
    
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.birthdayDate.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
        verifyTxt()
        
        
    }
    
    
}



