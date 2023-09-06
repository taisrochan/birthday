//
//  BirthdayDataViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 13/07/23.
//

import UIKit

protocol BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, day: String, id: String, month: String, birthday: Date)
    func editBirthdayInfo(name: String, day: String, id: String, month: String, birthday: Date)
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
    
    
    init(birthdayModel: BirthdayListModel? = nil) {
        self.birthdayModel = birthdayModel
        super.init(nibName: nil, bundle: nil)
        //        saveButton.backgroundColor = .blue
        print(view.frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pickerView = UIPickerView()
    var delegate: BirthdayDataViewControllerDelegate?
    let birthdayModel: BirthdayListModel?
    var images: [UIImage?] = []
    lazy var imagePickerController: UIImagePickerController = {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.sourceType = .photoLibrary
        imagePickerVC.delegate = self
        return imagePickerVC
    }()
    let months = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
    var selectedMonth = ""
    var daysInMonth: [String] = (1...31).map { String($0) }
    let monthsToNumber: [String: Int] = [
        "Janeiro": 1,
        "Fevereiro": 2,
        "Março": 3,
        "Abril": 4,
        "Maio": 5,
        "Junho": 6,
        "Julho": 7,
        "Agosto": 8,
        "Setembro": 9,
        "Outubro": 10,
        "Novembro": 11,
        "Dezembro": 12
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.backgroundColor = .orange
        //        print("frame: \(view.frame)")
        saveButton.isEnabled = false
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.white, for: .disabled)
        personTextField.addTarget(self,
                                  action: #selector(textFieldDidChange(_:)),
                                  for: .editingChanged)
        //        dateTextField.addTarget(self,
        //                                action: #selector(textFieldDidChange(_:)),
        //                                for: .editingChanged)
        //        dateTextField.clearButtonMode = .always
        
        //createDatePicker()
        
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
            
            configScreenIfIsEditingBirthday()
            
            pickerView.dataSource = self
            pickerView.delegate = self
            
            monthTextField.inputView = pickerView
            dayTextField.inputView = pickerView
            
            setupDoneButtonToolbar()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
        personTextField.text = model.name
        //        dateTextField.text = model.birthdayDate
        updateUIForEditingBirthday(false)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Editar",
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(editingDetails))
        getPicture()
    }
    
    @objc func editingDetails() {
        updateUIForEditingBirthday(true)
    }
    
    func updateUIForEditingBirthday(_ isEditing: Bool) {
        saveButton.backgroundColor = isEditing ? .orange : .gray
        personTextField.isEnabled = isEditing
        //        dateTextField.isEnabled = isEditing
        saveButton.isEnabled = isEditing
        addPhotoButton1.isEnabled = isEditing
        addPhotoButton2.isEnabled = isEditing
        addPhotoButton3.isEnabled = isEditing
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
        if person.isEmpty || month.isEmpty || day.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let name = personTextField.text ?? ""
        let month = monthTextField.text ?? ""
        let day = dayTextField.text ?? ""
        guard let monthNumber = monthsToNumber[month],
              let dayNumber = Int(day) else {
            return
        }
        var birthdaydate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd" // Formato da data com ano, mês e dia
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let dateComponents = DateComponents(year: year,
                                            month: monthNumber,
                                            day: dayNumber)
        if let date = calendar.date(from: dateComponents) {
            birthdaydate = date
        }
        
        let imagesToSave = images.compactMap { $0 }
        if let model = birthdayModel {
            UserDefaults.standard.set(imagesToSave, forKey: model.identifier)
            delegate?.editBirthdayInfo(name: name,
                                       day: day,
                                       id: model.identifier,
                                       month: String(monthNumber),
                                       birthday: model.birthday)
        } else {
            let id = UUID().uuidString
            delegate?.passBirthdayInfo(name: name,
                                       day: day,
                                       id: id,
                                       month: String(monthNumber),
                                       birthday: birthdaydate)
            UserDefaults.standard.set(imagesToSave, forKey: id)
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc func doneButtonPressed() {
        // Oculte o teclado (ou, neste caso, o pickerView) quando o botão "Pronto" for pressionado
        dayTextField.resignFirstResponder()
        monthTextField.resignFirstResponder()
        verifyTxt()
    }
    
    func setupDoneButtonToolbar() {
        let doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Pronto", style: .done, target: self, action: #selector(doneButtonPressed))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        doneToolbar.items = [flexSpace, doneButton]
        
        // Defina a UIToolbar como accessoryView para ambos os textFields
        dayTextField.inputAccessoryView = doneToolbar
        monthTextField.inputAccessoryView = doneToolbar
    }
    
    //
    //        func createToolBar() -> UIToolbar {
    //            let toolBar = UIToolbar ()
    //          toolBar.sizeToFit()
    //
    //            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
    //           toolBar.setItems([doneButton], animated: true)
    //
    //            return toolBar
    //       }
    
    //       func createDatePicker() {
    //    //        datePicker.preferredDatePickerStyle = .wheels
    //    //        datePicker.datePickerMode = .date
    //    //        dateTextField.inputView = datePicker
    //            dateTextField.inputAccessoryView = createToolBar()
    //
    //     }
    
    @objc func donePressed() {
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

extension BirthdayDataManagerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource & UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return months.count
        } else {
            return daysInMonth.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return months[row] // Exibe o mês
        } else {
            return daysInMonth[row] // Exibe o dia
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            // Mês foi selecionado
            selectedMonth = months[row]
            updateDaysInMonth()
            pickerView.reloadComponent(1) // Recarrega a coluna de dias
            pickerView.selectRow(0, inComponent: 1, animated: true)
            monthTextField.text = selectedMonth
        } else {
            // Dia foi selecionado
            let selectedDay = daysInMonth[row]
            dayTextField.text = selectedDay
        }
    }
    
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
        let month = selectedMonthIndex + 1 // Acrescentamos 1, pois os meses no componente começam em 0
        
        // Obtém o último dia do mês atual
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.day = 0
        if let lastDay = calendar.date(from: components) {
            let lastDayOfMonth = calendar.component(.day, from: lastDay)
            
            // Preenche a lista de dias com base no número de dias no mês
            daysInMonth = (1...lastDayOfMonth).map { String($0) }
        }
    }
}


