//
//  CustomTableViewCell.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 12/09/23.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    override var reuseIdentifier: String? {
        "birthdayCell"
    }
    
    @IBOutlet weak var birthdayDayLabel: UILabel!
    @IBOutlet weak var birthdayNameLabel: UILabel!
    
    var birthdayModel: BirthdayListModel?
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        birthdayNameLabel.textColor = .black
    }
    
    func passData(day: String, name: String) {
        birthdayDayLabel.text = day
        birthdayNameLabel.text = "-  \(name)"
    }
}
