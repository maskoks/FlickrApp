//
//  Photo.swift
//  FlickrApp
//
//  Created by Жеребцов Данил on 03.07.2021.
//

import Foundation
import SwiftyJSON


struct Photo {
    var bigImage: String
    var smallImage: String
    
    init?(json: JSON) {
        guard let urlQ = json["url_q"].string else {return nil}
        guard let urlC = json["url_c"].string else {return nil}
        
        self.bigImage = urlC
        self.smallImage = urlQ
        
    }
    
}


