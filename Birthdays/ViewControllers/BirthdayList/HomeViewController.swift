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
        return birthdayDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        } else {
            print("INDEX: \(indexPath.row)")
        }
        cell?.selectionStyle = .none
        cell?.textLabel?.text = birthdayDataArray[indexPath.row].name
        cell?.detailTextLabel?.text = birthdayDataArray[indexPath.row].birthdayDate
        return cell!
    }
    
    func tableview(_tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            birthdayDataArray.remove(at: indexPath.row)
            tableView.endUpdates()
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
        let editBirthday = BirthdayListModel(name: name, birthdayDate: birthday, identifier: id)
        for i in 0..<birthdayDataArray.count {
            if birthdayDataArray[i].identifier == id {
                birthdayDataArray[i].name = name
                birthdayDataArray[i].birthdayDate = birthday
            }
        }
        tableView.reloadData()
    }
}
