//
//  CollectionViewController.swift
//  FlickrApp
//
//  Created by Жеребцов Данил on 03.07.2021.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

private let reuseIdentifier = "Cell"



class CollectionViewController: UICollectionViewController, UISearchResultsUpdating, UICollectionViewDelegateFlowLayout {


    let myQueue = DispatchQueue(label: "com.com.my-work.personalQueue", qos: .userInteractive)
    let myQueue2 = DispatchQueue(label: "com.com.my-work.personalQueue", attributes: .concurrent)
    let group = DispatchGroup()
    
    
    var searchText = ""
//    var searchText = "" {
//        didSet {
//            self.request(searchCategory: searchText)
//        }
////    }
    var photoArray = [Photo]()
//    var photoArray = [Photo]() {
//        didSet {
//
//                self.collectionView.reloadData()
//
//
//        }
//    }
    
    let searchController = UISearchController()
    
    override func viewWillAppear(_ animated: Bool) {
        request()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isScrollEnabled = true
        
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
    }
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let data = URL(string: photoArray[indexPath.row].smallImage)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        
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
    
    func updateSearchResults(for searchController: UISearchController) {
        searchText = self.searchController.searchBar.text!
        
        myQueue.async {
            self.request()
        }
        
        myQueue.async(flags: .barrier) {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
   
    
    func request () {
        let url = URL(string: "https://www.flickr.com/services/rest/")!
        let parametrs = [
            "method" : "flickr.photos.search",
            "text" : searchText,
            "api_key" : "a758582ab3563b8221fd4dc644f9bd88",
            "sort" : "relevance",
            "per_page" : "60",
            "format" : "json",
            "nojsoncallback" : "1",
            "extras" : "url_q,url_c"
        ]
        
        AF.request(url, method: .get, parameters: parametrs).validate().responseData { (response) in
            switch response.result {
            case .success(_):

                guard let data = response.data else { return }
                guard let json = try? JSON(data: data) else { return }
                let photosJSON = json["photos"]["photo"]
                self.photoArray = photosJSON.arrayValue.compactMap { Photo(json: $0)}
                

            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
