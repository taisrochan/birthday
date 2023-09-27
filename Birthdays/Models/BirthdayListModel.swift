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
    
    var isDivisor = false
    
    static func createDivisorModel() -> BirthdayListModel {
        let valueAlwaysBiggerThanADay = "32"
        var model = BirthdayListModel(name: "", day: valueAlwaysBiggerThanADay, month: "", identifier: "", birthday: Date())
        model.isDivisor = true
        return model
    }
}
