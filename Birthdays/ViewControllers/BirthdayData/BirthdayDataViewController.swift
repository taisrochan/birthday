//
//  BirthdayDataViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 13/07/23.
//

import UIKit

protocol BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, birthday: String, id: String)
}

class BirthdayDataViewController: UIViewController {
    @IBOutlet weak var birthdayPerson: UITextField!
    @IBOutlet weak var birthdayDate: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addPhoto1: UIImageView!
    @IBOutlet weak var addPhoto2: UIImageView!
    @IBOutlet weak var addPhoto3: UIImageView!
    
    
    let datePicker = UIDatePicker()
    var delegate: BirthdayDataViewControllerDelegate?
    
    var images: [UIImage] = []
    
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

        _ = UITapGestureRecognizer(target: self,
                                                action: #selector(closeKeyboard))
        
        [addPhoto1, addPhoto2, addPhoto3].forEach { imageView in
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 10
        }
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
        let id = UUID().uuidString
        delegate?.passBirthdayInfo(name: name, birthday: birthday, id: id)
        
        UserDefaults.standard.set(images, forKey: id)
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

    func addPhoto() {
        guard images.count < 3 else {
            return
        }
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
//        imagePickerVC.allowsEditing = true
        present(imagePickerVC, animated: true)
//        view.endEditing(true)
    }
    
    @IBAction func addImage(_ sender: UIButton) {
        addPhoto()
    }
}

extension BirthdayDataViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        if images.count == 0 {
            addPhoto1.image = image
            addPhoto1.contentMode = .scaleAspectFill
        } else if images.count == 1 {
            addPhoto2.image = image
            addPhoto2.contentMode = .scaleAspectFill
        } else if images.count == 2 {
            addPhoto3.image = image
            addPhoto3.contentMode = .scaleAspectFill
        }
        images.append(image)
        
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    




