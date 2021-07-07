//
//  MainViewController.swift
//  FlickrApp
//
//  Created by Жеребцов Данил on 06.07.2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher





class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {

    var photoArray = [Photo]()
    let myQueue = DispatchQueue(label: "com.com.my-work.personalQueue", qos: .userInteractive)
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
       
        searchBar.delegate = self
        configureButtons(searchButton: searchButton, resetButton: resetButton)
        activityIndicator.isHidden = true
        
    }
    
    func configureButtons(searchButton: UIButton, resetButton: UIButton) {
        searchButton.layer.borderWidth = 1.0
        resetButton.layer.borderWidth = 1.0
        
        searchButton.layer.borderColor = UIColor.systemBlue.cgColor
        resetButton.layer.borderColor = UIColor.systemRed.cgColor
        
        searchButton.layer.cornerRadius = 20
        resetButton.layer.cornerRadius = 20
        
        searchButton.setTitleColor(.systemBlue, for: .normal)
        resetButton.setTitleColor(.systemRed, for: .normal)
    }
    
    
    @IBAction func searchButtonAction(_ sender: Any) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        request {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.view.endEditing(true)
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    
    @IBAction func resetButtonAction(_ sender: Any) {
        searchBar.text = ""
        photoArray.removeAll()
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchButtonAction(self)
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = URL(string: photoArray[indexPath.row].smallImage)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionViewCell", for: indexPath) as! PhotoCollectionViewCell
        cell.photoImageView.kf.setImage(with: data)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.width/3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPhotoVC = storyboard?.instantiateViewController(withIdentifier: "SelectedPhotoViewController") as! SelectedPhotoViewController
        navigationController?.pushViewController(selectedPhotoVC, animated: true)
        selectedPhotoVC.selectedPhoto = photoArray[indexPath.row].bigImage
    }
    
    func request(completion: (() -> Void)? = nil)  {
        let url = URL(string: "https://www.flickr.com/services/rest/")!
        let parametrs = [
            "method" : "flickr.photos.search",
            "text" : searchBar.text,
            "api_key" : "a758582ab3563b8221fd4dc644f9bd88",
            "sort" : "relevance",
            "per_page" : "60",
            "format" : "json",
            "nojsoncallback" : "1",
            "extras" : "url_q,url_c"
        ]
        
        AF.request(url, method: .get, parameters: parametrs).validate().responseData(queue: myQueue) { (response) in
            switch response.result {
            
            case .success(_):
                guard let data = response.data else { return }
                guard let json = try? JSON(data: data) else { return }
                let photosJSON = json["photos"]["photo"]
                self.photoArray = photosJSON.arrayValue.compactMap { Photo(json: $0)}
                completion?()
                

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
