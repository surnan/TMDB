//
//  RequestTokenResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation


struct RequestTokenResponse: Codable {
    var success: Bool
    var expires: String
    var requestToken: String
    
    
    enum CodingKeys: String, CodingKey {
        case success
        case expires = "expires_at"
        case requestToken = "request_token"
    }
}



