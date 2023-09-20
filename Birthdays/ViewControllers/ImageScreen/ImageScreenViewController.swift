//
//  ImageScreenViewController.swift
//  Birthdays
//
//  Created by Tais Rocha Nogueira on 20/09/23.
//

import UIKit

class ImageScreenViewController: UIViewController {

    @IBOutlet weak var fullPictureImageView: UIImageView!
    
    let imageReceveid: UIImage
    let nameReceveid: String
    
    
    init(imageReceveid: UIImage, nameReceveid: String) {
        self.imageReceveid = imageReceveid
        self.nameReceveid = nameReceveid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullPictureImageView.image = imageReceveid
        navigationItem.title = nameReceveid
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonTapped))
        navigationItem.rightBarButtonItem = shareButton
    }
    
    @objc func shareButtonTapped() {
        let imageToShare = fullPictureImageView.image
        let itemsToShare: [Any] = [imageToShare ?? ""]
                   
                   let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
                   
                   present(activityViewController, animated: true, completion: nil)
        }
        
    }

