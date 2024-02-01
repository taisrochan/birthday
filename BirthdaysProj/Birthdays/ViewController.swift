//
//  ViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 16/10/23.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

enum AppColors {
    static var descriptionLabel: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.white
            default:
                return UIColor.black
            }
        }
    }
    
    static var descriptionPlaceHolder: UIColor {
        return UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor.lightGray
            default:
                return UIColor.darkGray
            }
        }
    }
}
