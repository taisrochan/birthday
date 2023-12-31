//
//  BirthdayDataViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 13/07/23.
//

import UIKit

protocol BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, day: Int, id: String, month: Int)
    func editBirthdayInfo(name: String, day: Int, id: String, month: Int)
}

class BirthdayDataManagerViewController: UIViewController {
    @IBOutlet weak var personTextField: UITextField!
    @IBOutlet weak var monthTextField: UITextField!
    @IBOutlet weak var dayTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var addPhotoOneImageView: UIImageView!
    @IBOutlet weak var addPhotoTwoImageView: UIImageView!
    @IBOutlet weak var addPhotoThreeImageView: UIImageView!
    @IBOutlet weak var addPhotoButton3: UIButton!
    @IBOutlet weak var addPhotoButton2: UIButton!
    @IBOutlet weak var addPhotoButton1: UIButton!
    @IBOutlet weak var birthdayLabel: UILabel!
    
    init(birthdayModel: BirthdayListModel? = nil) {
        self.birthdayModel = birthdayModel
        self.isEditingBirthday = birthdayModel != nil
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var didClickButtonEdit = false
    var pickerView = UIPickerView()
    var delegate: BirthdayDataViewControllerDelegate?
    let birthdayModel: BirthdayListModel?
    let isEditingBirthday: Bool
    var images: [UIImage?] = []
    lazy var imagePickerController: UIImagePickerController = {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        return imagePickerVC
    }()
    
    var selectedMonth = ""
    var daysInMonth: [String] = (1...31).map { String($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.backgroundColor = .orange
        saveButton.isEnabled = false
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.white, for: .disabled)
        personTextField.addTarget(self,
                                  action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        monthTextField.rightView?.largeContentImage = .add
        
        _ = UITapGestureRecognizer(target: self,
                                   action: #selector(closeKeyboard))
        
        [addPhotoOneImageView, addPhotoTwoImageView, addPhotoThreeImageView].forEach { imageView in
            imageView.contentMode = .scaleAspectFit
            imageView.layer.cornerRadius = 10
        }
        
        [addPhotoButton1, addPhotoButton2, addPhotoButton3].forEach {
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self,
                                                                   action: #selector(longPressed))
            $0?.addGestureRecognizer(longPressRecognizer)
            
        }
        
        configScreenIfIsEditingBirthday()
        pickerView.dataSource = self
        pickerView.delegate = self
        monthTextField.inputView = pickerView
        dayTextField.inputView = pickerView
        setupDoneButtonToolbar()
        
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
        fillBirthdayInfos(birthDayModel: model)
        updateUIForEditingBirthday(false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Editar",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(editDetails))
        birthdayLabel.text = "Dados de Aniversário"
        
        getPicture()
    }
    
    func fillBirthdayInfos(birthDayModel: BirthdayListModel) {
        let monthShortString = birthDayModel.month.asString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        guard let monthAsDate = dateFormatter.date(from: monthShortString) else {
            return
        }
        dateFormatter.dateFormat = "MMMM"
        let monthLongString = dateFormatter.string(from: monthAsDate)
        
        personTextField.text = birthDayModel.name
        monthTextField.text = monthLongString.capitalized
        dayTextField.text = birthDayModel.day.asString
    }
    
    @objc func editDetails() {
        didClickButtonEdit = true
        updateUIForEditingBirthday(true)
    }
    
    func updateUIForEditingBirthday(_ isEditing: Bool) {
        saveButton.backgroundColor = isEditing ? .orange : .gray
        personTextField.isEnabled = isEditing
        dayTextField.isEnabled = isEditing
        monthTextField.isEnabled = isEditing
        saveButton.isEnabled = isEditing

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
        let month = monthTextField.text ?? ""
        let day = dayTextField.text ?? ""
        let emptyFields = person.isEmpty || month.isEmpty || day.isEmpty
        saveButton.isEnabled = !emptyFields
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let name = personTextField.text,
              let monthString = monthTextField.text,
              let day = Int(dayTextField.text ?? "grw"),
              let monthNumber = DateValuesProvider.monthsToNumber[monthString] else {
            return
        }
        
        let imagesToSave = images.compactMap { $0 }
        if let model = birthdayModel {
            UserDefaults.standard.set(imagesToSave, forKey: model.identifier)
            delegate?.editBirthdayInfo(name: name,
                                       day: day,
                                       id: model.identifier,
                                       month: monthNumber)
        } else {
            let id = UUID().uuidString
            delegate?.passBirthdayInfo(name: name,
                                       day: day,
                                       id: id,
                                       month: monthNumber)
            UserDefaults.standard.set(imagesToSave, forKey: id)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doneButtonPressed() {
        
        self.view.endEditing(true)
        checkMonthAndDayTextFields()
        verifyTxt()
    }
    
    func setupDoneButtonToolbar() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Pronto", style: .done, target: self, action: #selector(doneButtonPressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        doneToolbar.items = [flexSpace, doneButton]
        
        dayTextField.inputAccessoryView = doneToolbar
        monthTextField.inputAccessoryView = doneToolbar
    }
    
    @IBAction func configImageAction(_ sender: UIButton) {
        let shouldOpenImageScreen = isEditingBirthday && !didClickButtonEdit
        if shouldOpenImageScreen {
            if let image = isThereImageForButton(sender: sender) {
                openImageScreen(image: image)
                return
            }
        }
        
        let isCreatingBirthday = !isEditingBirthday
        if isCreatingBirthday || didClickButtonEdit {
            let shouldAddImage = sender.currentImage == nil
            if shouldAddImage {
                presentImagePicker()
            } else {
                deleteImage(button: sender)
            }
        }
    }
    
    func openImageScreen(image: UIImage) {
        let fullPictureScreen = ImageScreenViewController(imageReceveid: image, nameReceveid: birthdayModel?.name ?? "")
        navigationController?.pushViewController(fullPictureScreen, animated: true)
    }
    
    func isThereImageForButton(sender: UIButton) -> UIImage? {
        switch sender {
        case addPhotoButton1:
            return getImageOrNil(for: 0)
        case addPhotoButton2:
            return getImageOrNil(for: 1)
        case addPhotoButton3:
            return getImageOrNil(for: 2)
        default: return nil
        }
    }
    
    func getImageOrNil(for index: Int) -> UIImage? {
        if images.indices.contains(index) {
            return images[index]
        } else {
            return nil
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

extension BirthdayDataManagerViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if component == 0 {
            return DateValuesProvider.months.count
        } else {
            return daysInMonth.count
        }
        
    }
    
    func checkMonthAndDayTextFields() {
        
        if monthTextField.text?.isEmpty ?? true {
            monthTextField.text = "Janeiro"
        }
        
        if dayTextField.text?.isEmpty ?? true {
            dayTextField.text = "1"
        }
    }
    
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return DateValuesProvider.months[row]
        } else {
            return daysInMonth[row]
        }
    }
}


extension BirthdayDataManagerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            selectedMonth = DateValuesProvider.months[row]
            updateDaysInMonth()
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
            monthTextField.text = selectedMonth
        } else {
            let selectedDay = daysInMonth[row]
            dayTextField.text = selectedDay
        }
        
    }
}

extension BirthdayDataManagerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
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

private extension BirthdayDataManagerViewController {
    
    func updateDaysInMonth() {
        
        let selectedMonthIndex = pickerView.selectedRow(inComponent: 0)
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let month = selectedMonthIndex + 1
        
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.day = 0
        if let lastDay = calendar.date(from: components) {
            let lastDayOfMonth = calendar.component(.day, from: lastDay)
            
            daysInMonth = (1...lastDayOfMonth).map { String($0) }
        }
    }
}


