import UIKit

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