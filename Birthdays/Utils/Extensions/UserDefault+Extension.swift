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
    
    //    var birthdatListSaved: Codable {
    //        get {
    //            guard
    //                let data = UserDefaults.standard.data(forKey: birthdayKey),
    //                let savedItems = try? JSONDecoder().decode([BirthdayListModel].self, from: data)
    //            else {
    //                return
    //            }
    
}

extension UserDefaults {
    func imageArray(forKey key: String) -> [UIImage]? {
        guard let array = self.array(forKey: key) as? [Data] else {
            return nil
        }
        let imageArray = array.compactMap({
            UIImage(data: $0)
        })
        return imageArray
    }

    func set(_ imageArray: [UIImage], forKey key: String) {
        let imageDataArray = imageArray.compactMap {
            $0.pngData
        }
        self.set(imageDataArray, forKey: key)
    }
}

