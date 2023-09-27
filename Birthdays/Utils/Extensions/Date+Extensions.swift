//
//  Date+Extensions.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 27/09/23.
//

import Foundation

extension Date {
    var year: Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        return year
    }

    var month: Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        return month
    }
}
