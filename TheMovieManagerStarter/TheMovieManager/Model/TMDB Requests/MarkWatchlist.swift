//
//  MarkWatchlist.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation


struct MarkWatchList: Codable{
    var mediaType: String
    var mediaId: Int
    var watchlist: Bool     //Add or Delete from watchlist
    
    
    enum CodingKeys: String, CodingKey {
        case mediaType = "media_type"
        case mediaId = "media_id"
        case watchlist
    }
}




