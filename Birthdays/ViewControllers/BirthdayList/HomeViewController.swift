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
    var birthdayDataMatrix: [[BirthdayListModel]] = [] {
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
            let savedItems = try? JSONDecoder().decode([[BirthdayListModel]].self, from: data)
        else {
            return
        }
        birthdayDataMatrix = savedItems
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
    
    func verifyIfThereIsValueOnTableView() {
        emptyTableViewLabel.isHidden = false
        if birthdayDataMatrix.count == 0 {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
    }
    
    func saveItems() {
        if let encondedData = try? JSONEncoder().encode(birthdayDataMatrix) {
            UserDefaults.standard.set(encondedData, forKey: birthdayKey)
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let element = birthdayDataMatrix[indexPath.section][indexPath.row]
        let birthdayDataViewController = BirthdayDataManagerViewController(birthdayModel: element)
        navigationController?.pushViewController(birthdayDataViewController, animated: true)
        birthdayDataViewController.delegate = self
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birthdayDataMatrix[section].count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return birthdayDataMatrix.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        let month = birthdayDataMatrix[section][0].month
        
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
  
        cell?.selectionStyle = .none
        let element = birthdayDataMatrix[indexPath.section][indexPath.row]
        cell?.textLabel?.text = element.name
        cell?.detailTextLabel?.text = element.birthdayDate
        return cell!
    }
    
    func tableview(_tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            birthdayDataMatrix[indexPath.section].remove(at: indexPath.row)
            if birthdayDataMatrix[indexPath.section].isEmpty {
                birthdayDataMatrix.remove(at: indexPath.section)
            }
            tableView.reloadData()
            verifyIfThereIsValueOnTableView()
        }
    }
}

extension HomeViewController: BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, birthday: String, id: String, month: String) {
        let newBirthday = BirthdayListModel(name: name,
                                            birthdayDate: birthday,
                                            month: month,
                                            identifier: id)
        
        var didAppendMonth = false
        birthdayDataMatrix.enumerated().forEach { (index, monthArray) in
            guard monthArray.indices.contains(0) else {
                return
            }
            if monthArray[0].month == month {
                birthdayDataMatrix[index].append(newBirthday)
                didAppendMonth = true
            }
        }
        if didAppendMonth == false {
            birthdayDataMatrix.append([newBirthday])
        }
        
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
    
    func editBirthdayInfo(name: String, birthday: String, id: String, month: String) {
        for j in 0..<birthdayDataMatrix.count {
            for i in 0...(birthdayDataMatrix[j].count-1) {
                if birthdayDataMatrix[j][i].identifier == id {
                    birthdayDataMatrix[j].remove(at: i)
                    if birthdayDataMatrix[j].isEmpty {
                        birthdayDataMatrix.remove(at: j)
                    }
                    break
                }
            }
        }
        passBirthdayInfo(name: name, birthday: birthday, id: id, month: month)
        tableView.reloadData()
        
    }
}
