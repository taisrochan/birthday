//
//  ViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 11/07/23.
//
import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var emptyTableViewLabel: UILabel!
    
    let tableView = UITableView()
    var birthdayDataArray: [BirthdayListModel] = [] {
        didSet {
            saveItems()
        }
    }
    
    let birthdayKey: String = "birthdayData_list"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configTableView()
        configNavigationBar()
        verifyIfThereIsValueOnTableView()
        fetchBirthdayData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    @objc func  buttonPressed() {
        let birthdayDataViewController = BirthdayDataManagerViewController()
        navigationController?.pushViewController(birthdayDataViewController, animated: true)
        birthdayDataViewController.delegate = self
    }
    
    func configTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    
    }
    
    func configNavigationBar() {
        navigationItem.title = "Lista de Aniversários"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "plus"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(buttonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .orange
        navigationController?.navigationBar.tintColor = .blue
    }
    
    func fetchBirthdayData() {
        guard
            let data = UserDefaults.standard.data(forKey: birthdayKey),
            let savedItems = try? JSONDecoder().decode([BirthdayListModel].self, from: data)
        else {
            return
        }
        birthdayDataArray = savedItems
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
    
    func verifyIfThereIsValueOnTableView() {
        if birthdayDataArray.count == 0 {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
    }
    
    func saveItems() {
        if let encondedData = try? JSONEncoder().encode(birthdayDataArray) {
            UserDefaults.standard.set(encondedData, forKey: birthdayKey)
        }
    }
    
    func getArrayOfMonths() -> [String] {
        let arrayOfDates = birthdayDataArray.map {
            return $0.birthdayDate
        }
        let arrayOfMonths = arrayOfDates.map { dateOfTheCurrentIndex in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            if let date = dateFormatter.date(from: dateOfTheCurrentIndex) {
                let dateFormatterMonth = DateFormatter()
                dateFormatterMonth.dateFormat = "MM"
                let month = dateFormatterMonth.string(from: date)
                return month
            }
            return ""
        }
        var uniqueMonths = Array(Set(arrayOfMonths))
        uniqueMonths.sort {
            $0 < $1
        }
        return uniqueMonths
    }
    
    func getArrayOfModelsWithShortDate() -> [BirthdayListModel] {
        let newArray = birthdayDataArray.map { birthday in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let date = dateFormatter.date(from: birthday.birthdayDate) ?? Date()
            let dateFormatterMonth = DateFormatter()
            dateFormatterMonth.dateFormat = "MM"
            let month = dateFormatterMonth.string(from: date)
            return BirthdayListModel(name: birthday.name,
                                     birthdayDate: month,
                                     identifier: birthday.identifier)
        }
        return newArray
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position = indexPath.row
        let model = birthdayDataArray[position]
        let birthdayDataViewController = BirthdayDataManagerViewController(birthdayModel: model)
        navigationController?.pushViewController(birthdayDataViewController, animated: true)
        birthdayDataViewController.delegate = self
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let months = getArrayOfMonths()
        let month = months[section]
        let birthdays = getArrayOfModelsWithShortDate()
        let birthdaysFromSpecificMonth = birthdays.filter {
            $0.birthdayDate == month
        }
        return birthdaysFromSpecificMonth.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let array = getArrayOfMonths()
        return array.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let months = getArrayOfMonths()
        let month = months[section]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let date = dateFormatter.date(from: month) ?? Date()
        
        let nameMonthFormatter = DateFormatter()
        nameMonthFormatter.dateFormat = "MMMM"
        let title = nameMonthFormatter.string(from: date)
        
        return title.capitalized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        } else {
            print("INDEX: \(indexPath.row)")
        }
        
        let months = getArrayOfMonths()
        let month = months[indexPath.section]
        let birthdays = getArrayOfModelsWithShortDate()
        let birthdaysFromSpecificMonth = birthdays.filter {
            $0.birthdayDate == month
        }
        let birthday = birthdayDataArray.first {
            $0.identifier == birthdaysFromSpecificMonth[indexPath.row].identifier
        }
        
        cell?.selectionStyle = .none
        cell?.textLabel?.text = birthdaysFromSpecificMonth[indexPath.row].name
        cell?.detailTextLabel?.text = birthday?.birthdayDate
        return cell!
    }
    
    func tableview(_tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            birthdayDataArray.remove(at: indexPath.row)
            tableView.reloadData()
            verifyIfThereIsValueOnTableView()
        }
    }
}

extension HomeViewController: BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, birthday: String, id: String) {
        let newBirthday = BirthdayListModel(name: name,
                                            birthdayDate: birthday,
                                            identifier: id)
        birthdayDataArray.append(newBirthday)
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
    
    func editBirthdayInfo(name: String, birthday: String, id: String) {
        for i in 0..<birthdayDataArray.count {
            if birthdayDataArray[i].identifier == id {
                birthdayDataArray[i].name = name
                birthdayDataArray[i].birthdayDate = birthday
            }
        }
        tableView.reloadData()
    }
}
