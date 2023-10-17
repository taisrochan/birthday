//
//  BirthdayListModel.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 01/08/23.
//

import Foundation

struct BirthdayListModel: Codable {
    var name: String
    var day: Int
    var month: Int
    let identifier: String
    
    var isDivisor = false
    
    static func createDivisorModel() -> BirthdayListModel {
        let valueAlwaysBiggerThanADay = 32
        var model = BirthdayListModel(name: "", day: valueAlwaysBiggerThanADay, month: 0, identifier: "")
        model.isDivisor = true
        return model
    }
}

extension Int {
    var asString: String {
        return "\(self)"
    }
}
