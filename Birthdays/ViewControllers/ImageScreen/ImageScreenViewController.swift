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
    
    init(imageReceveid: UIImage) {
        self.imageReceveid = imageReceveid
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fullPictureImageView.image = imageReceveid
        //pode ser que não esteja certo

    }



}
