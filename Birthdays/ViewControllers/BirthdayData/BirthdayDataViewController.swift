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
    @IBOutlet weak var personTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addPhoto1: UIImageView!
    @IBOutlet weak var addPhoto2: UIImageView!
    @IBOutlet weak var addPhoto3: UIImageView!
    
    init(birthdayModel: BirthdayListModel? = nil) {
        self.birthdayModel = birthdayModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let datePicker = UIDatePicker()
    var delegate: BirthdayDataViewControllerDelegate?
    let birthdayModel: BirthdayListModel?
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        personTextField.addTarget(self,
                                  action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
        dateTextField.addTarget(self,
                                action: #selector(textFieldDidChange(_:)),
                                for: .editingChanged)
        dateTextField.clearButtonMode = .always
        
        createDatePicker()
        
        _ = UITapGestureRecognizer(target: self,
                                   action: #selector(closeKeyboard))
        
        [addPhoto1, addPhoto2, addPhoto3].forEach { imageView in
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 10
        }
        
        if birthdayModel != nil {
            personTextField.text = birthdayModel?.name
            personTextField.isEnabled = false
            dateTextField.text = birthdayModel?.birthdayDate
            dateTextField.isEnabled = false
            saveButton.isEnabled = false
            getPicture()
        }
    }
    
    func getPicture() {
        if let model = birthdayModel {
            let images = UserDefaults.standard.imageArray(forKey: model.identifier) ?? []
            if images.indices.contains(0) {
                addPhoto1.image = images[0]
                addPhoto1.contentMode = .scaleAspectFill
            }
            if images.indices.contains(1) {
                addPhoto2.image = images[1]
                addPhoto2.contentMode = .scaleAspectFill
            }
            if images.indices.contains(2) {
                addPhoto3.image = images[2]
                addPhoto3.contentMode = .scaleAspectFill
            }
            
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
        let person = personTextField.text ?? ""
        let birthday = dateTextField.text ?? ""
        if person.isEmpty || birthday.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let name = personTextField.text ?? ""
        let birthday = dateTextField.text ?? ""
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
        
        dateTextField.inputView = datePicker
        dateTextField.inputAccessoryView = createToolBar()
    }
    
    @objc func donePressed() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        self.dateTextField.text = dateFormatter.string(from: datePicker.date)
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}






