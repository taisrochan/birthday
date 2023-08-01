//
//  ViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 11/07/23.
//
import UIKit

struct BirthdayListModel: Codable {
    let name: String
    let birthdayDate: String
    let identifier: String
}

// criar ela e colocar na tela (UItableView)
// atribuir o delegate e o datasource para self

//delegate da tableView
// acoes da tableview
// clique na celula, se vc scrollou a tableView, se uma celula apareceu ou vai aparecer

// datasource da tableView
// numberOfRows e cellForRow (obrigatorios)
// cellForRow é onde vc cria a celula e PASSA OS VALORES que vao aparecer na celula
// numberOfSections, headerForSection, ... (opcionais)

class ViewController: UIViewController {
    
    @IBOutlet weak var emptyTableViewLabel: UILabel!
    
    let tableView = UITableView()
    var birthdayData: [BirthdayListModel] = [] {
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
        let birthdayDataViewController = BirthdayDataViewController()
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
        birthdayData = savedItems
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
    
    func verifyIfThereIsValueOnTableView() {
        if birthdayData.count == 0 {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
    }
    
    func saveItems() {
        if let encondedData = try? JSONEncoder().encode(birthdayData) {
            UserDefaults.standard.set(encondedData, forKey: birthdayKey)
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let position = indexPath.row
        let model = birthdayData[position]
        let birthdayDataViewController = BirthdayDataViewController(birthdayModel: model)
        navigationController?.pushViewController(birthdayDataViewController, animated: true)
        birthdayDataViewController.delegate = self
    }
}
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return birthdayData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        } else {
            print("INDEX: \(indexPath.row)")
        }
        cell?.selectionStyle = .none
        
        cell!.textLabel?.text = birthdayData[indexPath.row].name
        cell!.detailTextLabel?.text = birthdayData[indexPath.row].birthdayDate
        
        
        
        return cell!
    }
    
    func tableview(_tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
        
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            birthdayData.remove(at: indexPath.row)
            tableView.endUpdates()
            verifyIfThereIsValueOnTableView()
        }
    
    }
}

extension ViewController: BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, birthday: String, id: String) {
        let newBirthday = BirthdayListModel(name: name,
                                            birthdayDate: birthday,
                                            identifier: id)
        birthdayData.append(newBirthday)
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
}
