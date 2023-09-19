//
//  BirthdayListModel.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 01/08/23.
//

import Foundation

struct BirthdayListModel: Codable {
    var name: String
    var day: String
    var month: String
    let identifier: String
    var birthday: Date
}
