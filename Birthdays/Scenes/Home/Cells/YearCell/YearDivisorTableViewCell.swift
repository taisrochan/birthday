//
//  YearDivisorTableViewCell.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 26/09/23.
//

import UIKit

class YearDivisorTableViewCell: UITableViewCell {
    override var reuseIdentifier: String? {
        "yearCell"
    }

    @IBOutlet weak var yearLabel: UILabel!
    
    func pass(year: String) {
        yearLabel.text = year
    }
}
