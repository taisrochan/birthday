//
//  BirthdayDataViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 13/07/23.
//

import UIKit

protocol BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, birthday: String, id: String)
    func editBirthdayInfo(name: String, birthday: String, id: String)
}

class BirthdayDataManagerViewController: UIViewController {
    @IBOutlet weak var personTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addPhotoOneImageView: UIImageView!
    @IBOutlet weak var addPhotoTwoImageView: UIImageView!
    @IBOutlet weak var addPhotoThreeImageView: UIImageView!
    @IBOutlet weak var addPhotoButton3: UIButton!
    @IBOutlet weak var addPhotoButton2: UIButton!
    @IBOutlet weak var addPhotoButton1: UIButton!
    
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
    var images: [UIImage?] = []
    lazy var imagePickerController: UIImagePickerController = {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        return imagePickerVC
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.white, for: .disabled)
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
        
        [addPhotoOneImageView, addPhotoTwoImageView, addPhotoThreeImageView].forEach { imageView in
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 10
        }
        
        configScreenIfIsEditingBirthday()
        
        [addPhotoButton1, addPhotoButton2, addPhotoButton3].forEach {
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                                   action: #selector(longPressed))
            $0?.addGestureRecognizer(longPressRecognizer)
        }
        
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if sender.view == addPhotoButton1 && images.indices.contains(0) {
            addPhotoOneImageView.alpha = 0.5
            let image = UIImage
                .init(systemName: "trash")?
                .withRenderingMode(.alwaysTemplate)
            addPhotoButton1.setImage(image, for: .normal)
            addPhotoButton1.tintColor = .red
        }
        if sender.view == addPhotoButton2 && images.indices.contains(1) {
            addPhotoTwoImageView.alpha = 0.5
            let image = UIImage
                .init(systemName: "trash")?
                .withRenderingMode(.alwaysTemplate)
            addPhotoButton2.setImage(image, for: .normal)
            addPhotoButton2.tintColor = .red
        }
        if sender.view == addPhotoButton3 && images.indices.contains(2) {
            addPhotoThreeImageView.alpha = 0.5
            let image = UIImage
                .init(systemName: "trash")?
                .withRenderingMode(.alwaysTemplate)
            addPhotoButton3.setImage(image, for: .normal)
            addPhotoButton3.tintColor = .red
        }
        
    }
    
    func configScreenIfIsEditingBirthday() {
        guard let model = birthdayModel else {
            return
        }
        saveButton.backgroundColor = .gray
        personTextField.text = model.name
        personTextField.isEnabled = false
        dateTextField.text = model.birthdayDate
        dateTextField.isEnabled = false
        saveButton.isEnabled = false
        addPhotoButton1.isEnabled = false
        addPhotoButton2.isEnabled = false
        addPhotoButton3.isEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Editar",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(editarDetalhes))
        getPicture()
    }
    
    @objc func editarDetalhes() {
        saveButton.backgroundColor = .orange
        personTextField.isEnabled = true
        dateTextField.isEnabled = true
        saveButton.isEnabled = true
        addPhotoButton1.isEnabled = true
        addPhotoButton2.isEnabled = true
        addPhotoButton3.isEnabled = true
    }
    
    func getPicture() {
        if let model = birthdayModel {
            let imagesFromUserDefaults = UserDefaults.standard.imageArray(forKey: model.identifier) ?? []
            if imagesFromUserDefaults.indices.contains(0) {
                addPhotoOneImageView.image = imagesFromUserDefaults[0]
                addPhotoOneImageView.contentMode = .scaleAspectFill
            }
            if imagesFromUserDefaults.indices.contains(1) {
                addPhotoTwoImageView.image = imagesFromUserDefaults[1]
                addPhotoTwoImageView.contentMode = .scaleAspectFill
            }
            if imagesFromUserDefaults.indices.contains(2) {
                addPhotoThreeImageView.image = imagesFromUserDefaults[2]
                addPhotoThreeImageView.contentMode = .scaleAspectFill
            }
            images = imagesFromUserDefaults
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
        
        let imagesToSave = images.compactMap { $0 }
        if let model = birthdayModel {
            UserDefaults.standard.set(imagesToSave, forKey: model.identifier)
            delegate?.editBirthdayInfo(name: name, birthday: birthday, id: model.identifier)
        } else {
            let id = UUID().uuidString
            delegate?.passBirthdayInfo(name: name, birthday: birthday, id: id)
            UserDefaults.standard.set(imagesToSave, forKey: id)
        }
        
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


    @IBAction func configImageAction(_ sender: UIButton) {
        let shouldAddImage = sender.currentImage == nil
        if shouldAddImage {
            presentImagePicker()
        } else {
            deleteImage(button: sender)
        }
    }
    
    func presentImagePicker() {
        guard images.count < 3 else {
            return
        }
        present(imagePickerController, animated: true)
    }
    
    func deleteImage(button: UIButton) {
        button.setImage(nil, for: .normal)
        button.tintColor = .clear
        switch button {
        case addPhotoButton1:
            resetImageView(index: 0, imageView: addPhotoOneImageView)
        case addPhotoButton2:
            resetImageView(index: 1, imageView: addPhotoTwoImageView)
        case addPhotoButton3:
            resetImageView(index: 2, imageView: addPhotoThreeImageView)
        default: break
        }
    }
    
    func resetImageView(index: Int, imageView: UIImageView) {
        let image = UIImage.init(systemName: "plus.app.fill")
        images[index] = nil
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
}

extension BirthdayDataManagerViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        if images.count == 0 {
            addPhotoOneImageView.image = image
            addPhotoOneImageView.contentMode = .scaleAspectFill
        } else if images.count == 1 {
            addPhotoTwoImageView.image = image
            addPhotoTwoImageView.contentMode = .scaleAspectFill
        } else if images.count == 2 {
            addPhotoThreeImageView.image = image
            addPhotoThreeImageView.contentMode = .scaleAspectFill
        }
        images.append(image)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}


