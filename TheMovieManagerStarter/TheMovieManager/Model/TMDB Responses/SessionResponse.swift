//
//  SessionResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation


struct SessionResponse: Codable {
    var success: Bool
    var session: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case session = "session_id"
    }
}
