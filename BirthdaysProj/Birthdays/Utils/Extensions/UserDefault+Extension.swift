//
//  UserDefault+Extension.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 20/07/23.
//

import Foundation
import UIKit

extension UserDefaults {
    private enum UserDefaultsKeys: String {
        case hasOnboarded
        case birthdayListSaved
    }
    
    var hasOnboarded: Bool {
        get {
            bool(forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
        set {
            setValue(newValue, forKey: UserDefaultsKeys.hasOnboarded.rawValue)
        }
    }
    
    var birthdayList: [[BirthdayListModel]] {
        set {
            if let encondedData = try? JSONEncoder().encode(newValue) {
                setValue(encondedData, forKey: UserDefaultsKeys.birthdayListSaved.rawValue)
            }
        }
        get {
            let key = UserDefaultsKeys.birthdayListSaved.rawValue
            if let data = UserDefaults.standard.data(forKey: key),
               let savedItems = try? JSONDecoder().decode([[BirthdayListModel]].self, from: data) {
                return savedItems
            } else {
                return []
            }
        }
    }
}

extension UserDefaults {
    func imageArray(forKey key: String) -> [String]? {
        guard let array = self.array(forKey: key) as? [String] else {
            return nil
        }
        let imageArray = array.compactMap({
            string(forKey: $0)
        })
        return imageArray
    }
}
