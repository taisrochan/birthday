//
//  HomeCoordinator.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 21/02/24.
//

import Foundation
import UIKit

class HomeCoordinator {
    var viewController: HomeViewController?
    
    func showAddBirthdayScreen() {
        let birthdayDataViewController = BirthdayDataManagerViewController()
        viewController?.navigationController?.pushViewController(birthdayDataViewController, animated: true)
        birthdayDataViewController.delegate = viewController
    }
}
