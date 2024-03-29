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
    var birthdayDataMatrix: [[BirthdayListModel]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "birthdayCell")
        tableView.register(UINib(nibName: "YearDivisorTableViewCell", bundle: nil), forCellReuseIdentifier: "yearCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
    }
    
    func configNavigationBar() {
        navigationItem.title = "Lista de Aniversários"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.init(systemName: "plus"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(buttonPressed))
        navigationItem.rightBarButtonItem?.tintColor = .orange
        navigationController?.navigationBar.tintColor = .orange
    }
    
    func fetchBirthdayData() {
        let savedItems = UserDefaults.standard.birthdayList.filter { !$0.isEmpty }
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
    
    func sortMonthsAndBirthdays() {
        guard birthdayDataMatrix.count > 0 else {
            return
        }
        deleteEmptyArraysIfExisted()
        ordenateMonthsInSections()
        manageNextYearCell()
        passNextMonthsFromThisYearToMatrixBeggining()
        ordenateBirthdayDatesInsideMonths()
    }
    
    func deleteEmptyArraysIfExisted() {
        birthdayDataMatrix = birthdayDataMatrix.filter { $0.count > 0 }
    }
    
    func ordenateMonthsInSections() {
        let orderedMatrix = birthdayDataMatrix.sorted {
            (Int($0[0].month) ) < (Int($1[0].month) )
        }
        birthdayDataMatrix = orderedMatrix
    }
    
    func passNextMonthsFromThisYearToMatrixBeggining() {
        let currentDate = Date()
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "MM"
        let month = dateFormater.string(from: currentDate)
        
        var indice: Int?
        for j in 0..<birthdayDataMatrix.count {
            let indiceMont = birthdayDataMatrix[j][0].month
            if Int(indiceMont) >= Int(month) ?? 0 {
                indice = j
                break
            }
        }
        guard let indice = indice else {
            return
        }
        
        let arraySlice = birthdayDataMatrix[indice..<birthdayDataMatrix.endIndex]
        print(arraySlice)
        
        let lastIndex = birthdayDataMatrix.count - 1
        
        for j in (indice...lastIndex).reversed() {
            birthdayDataMatrix.remove(at: j)
        }
        print(birthdayDataMatrix)
        
        birthdayDataMatrix.insert(contentsOf: arraySlice, at: 0)
    }
    
    func ordenateBirthdayDatesInsideMonths() {
        
        guard birthdayDataMatrix.count > 0 else {
            return
        }
        for j in 0..<birthdayDataMatrix.count{
            let month = birthdayDataMatrix[j]
            let orderedBirthdays = month.sorted {
                Int($0.day) < Int($1.day)
            }
            birthdayDataMatrix.remove(at: j)
            birthdayDataMatrix.insert(orderedBirthdays, at: j)
        }
    }
    
    func saveBirthdayList() {
        UserDefaults.standard.birthdayList = birthdayDataMatrix
    }
    
    func manageNextYearCell() {
    outerLoop: for j in 0..<birthdayDataMatrix.count {
        for i in 0...(birthdayDataMatrix[j].count-1) {
            if birthdayDataMatrix[j][i].isDivisor {
                birthdayDataMatrix[j].remove(at: i)
                break outerLoop
            }
        }
    }
        deleteEmptyArraysIfExisted()
        let yearDivisorModel = BirthdayListModel.createDivisorModel()
        guard let lastIndice = birthdayDataMatrix.indices.last else {
            return
        }
        let currentMonth = Date.now.month
        let lastMonth = birthdayDataMatrix[lastIndice][0].month
        let thereIsMonthBiggerThanCurrentMonth = lastMonth >= currentMonth
        let firstMonth = birthdayDataMatrix[0][0].month
        let thereIsMonthSmallerThanCurrentMonth = currentMonth > firstMonth
        let shouldAddYearCell = thereIsMonthBiggerThanCurrentMonth && thereIsMonthSmallerThanCurrentMonth
        if shouldAddYearCell {
            birthdayDataMatrix[lastIndice].append(yearDivisorModel)
            
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isDivisor = birthdayDataMatrix[indexPath.section][indexPath.row].isDivisor
        guard isDivisor == false else {
            return
        }
        let element = birthdayDataMatrix[indexPath.section][indexPath.row]
        let birthdayDataViewController = BirthdayDataManagerViewController(birthdayModel: element)
        navigationController?.pushViewController(birthdayDataViewController, animated: true)
        birthdayDataViewController.delegate = self
    }
    
    func tableview(_tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteCellAlert(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let cell = tableView.cellForRow(at: indexPath)
        if cell is YearDivisorTableViewCell {
            return false
        }
        return true
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
        
        let month = birthdayDataMatrix[section][0].month.asString
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let date = dateFormatter.date(from: month) ?? Date()
        
        let nameMonthFormatter = DateFormatter()
        nameMonthFormatter.dateFormat = "MMMM"
        nameMonthFormatter.locale = Locale(identifier: "pt_BR")
        let title = nameMonthFormatter.string(from: date)
        
        return title.capitalized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        let element = birthdayDataMatrix[indexPath.section][indexPath.row]
        if element.isDivisor {
            let newCell = tableView.dequeueReusableCell(withIdentifier: "yearCell", for: indexPath) as! YearDivisorTableViewCell
            let nextYear = Date.now.year + 1
            let year = nextYear.asString
            newCell.pass(year: year)
            cell = newCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "birthdayCell", for: indexPath) as! CustomTableViewCell
            (cell as? CustomTableViewCell)?.passData(day: element.day, name: element.name)
        }
        cell.selectionStyle = .none
        return cell
    }
}

extension HomeViewController: BirthdayDataViewControllerDelegate {
    func passBirthdayInfo(name: String, day: Int, id: String, month: Int) {
        let newBirthday = BirthdayListModel(name: name, day: day, month: month, identifier: id)
        
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
        saveBirthdayList()
        sortMonthsAndBirthdays()
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
    
    func editBirthdayInfo(name: String, day: Int, id: String, month: Int) {
    outerLoop: for j in 0..<birthdayDataMatrix.count {
        for i in 0...(birthdayDataMatrix[j].count-1) {
            if birthdayDataMatrix[j][i].identifier == id {
                birthdayDataMatrix[j].remove(at: i)
                if birthdayDataMatrix[j].isEmpty {
                    birthdayDataMatrix.remove(at: j)
                }
                break outerLoop
            }
        }
    }
        passBirthdayInfo(name: name, day: day, id: id, month: month)
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
        deleteEmptyArraysIfExisted()
        saveBirthdayList()
        sortMonthsAndBirthdays()
        tableView.reloadData()
        verifyIfThereIsValueOnTableView()
    }
}
