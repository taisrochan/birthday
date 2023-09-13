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
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "birthdayCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        view.backgroundColor = .white
        configTableView()
        configNavigationBar()
        verifyIfThereIsValueOnTableView()
        fetchBirthdayData()
        sortMonthsAndBirthdays()
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
    
    func sortMonthsAndBirthdays() {
        ordenateMonthsInSections()
        ordenateBirthdayDatesInMonths()
    }
    
    func ordenateBirthdayDatesInMonths() {
        
        guard birthdayDataMatrix.count > 0 else {
            return
        }
        for j in 0..<birthdayDataMatrix.count{
            let month = birthdayDataMatrix[j]
            let orderedBirthdays = month.sorted {
                $0.day < $1.day
            }
            birthdayDataMatrix.remove(at: j)
            birthdayDataMatrix.insert(orderedBirthdays, at: j)
        }
    }
    
    func ordenateMonthsInSections() {
        guard birthdayDataMatrix.count > 0 else {
            return
        }
        //1. Ordernar os meses das sections em ordem crescente
        let orderedMatrix = birthdayDataMatrix.sorted {
            (Int($0[0].month) ?? 0) < (Int($1[0].month) ?? 0)
        }
        birthdayDataMatrix = orderedMatrix
        
        //2. Pegar date como String da data de hoje
        let currentDate = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM"
        let month = dateFormater.string(from: currentDate)
        
        //Descobrir qual indice da matriz em que o array corresponde ao mês atual
        var indice: Int?
        for j in 0..<birthdayDataMatrix.count {
            let indiceMont = birthdayDataMatrix[j][0].month
            if Int(indiceMont) ?? 0 >= Int(month) ?? 0 {
                indice = j
                break
            }
        }
        guard let indice = indice else {
            return
        }
        // Pegar fatia da matriz que começa no índice descoberto e copiar essa fatia para uma nova propriedade
        
        let arraySlice = birthdayDataMatrix[indice..<birthdayDataMatrix.endIndex]
        print(arraySlice)
        
        // Remover essa fatia da matriz
        
        let lastIndex = birthdayDataMatrix.count - 1
        
        for j in (indice...lastIndex).reversed() {
            birthdayDataMatrix.remove(at: j)
        }
        print(birthdayDataMatrix)
        
        // Inserir a copia no inicio da matriz
        
        birthdayDataMatrix.insert(contentsOf: arraySlice, at: 0)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCell", for: indexPath) as! CustomTableViewCell
        
        cell.selectionStyle = .none
        let element = birthdayDataMatrix[indexPath.section][indexPath.row]
        cell.passData(day: element.day, name: element.name)
        return cell
    }
    
    func tableview(_tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteCellAlert(indexPath: indexPath)
        }
    }
}

extension HomeViewController: BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, day: String, id: String, month: String, birthday: Date) {
        let newBirthday = BirthdayListModel(name: name, day: day, month: month, identifier: id, birthday: birthday)
        
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
        sortMonthsAndBirthdays()
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
        
        
    }
    
    func editBirthdayInfo(name: String, day: String, id: String, month: String, birthday: Date) {
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
        
        passBirthdayInfo(name: name, day: day, id: id, month: month, birthday: birthday)
        
    }
}

private extension HomeViewController {
    func showDeleteCellAlert(indexPath: IndexPath) {
        let alertController = UIAlertController(title: "Confirmação",
                                                message: "Tem certeza de que deseja excluir este item?",
                                                preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Excluir", style: .destructive) { (action) in
            self.deleteCell(indexPath: indexPath)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteCell(indexPath: IndexPath) {
       birthdayDataMatrix[indexPath.section].remove(at: indexPath.row)
        if birthdayDataMatrix[indexPath.section].isEmpty {
            birthdayDataMatrix.remove(at: indexPath.section)
        }
        
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
}

    




