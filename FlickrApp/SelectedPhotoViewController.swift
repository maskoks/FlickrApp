//
//  SelectedPhotoViewController.swift
//  FlickrApp
//
//  Created by Жеребцов Данил on 07.07.2021.
//

import UIKit
import Kingfisher

class SelectedPhotoViewController: UIViewController {
    
    
    var selectedPhoto = ""
    
    @IBOutlet weak var selectedPhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let data = URL(string: selectedPhoto)
        selectedPhotoImageView.kf.setImage(with: data)
    }
}
