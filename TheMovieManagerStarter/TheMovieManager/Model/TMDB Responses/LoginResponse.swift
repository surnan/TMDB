//
//  LoginResponse.swift
//  TheMovieManager
//
//  Created by admin on 1/26/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    var success: Bool
    var expiresAt: String
    var requestToken: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case expiresAt = "expires_at"
        case requestToken = "request_token"
    }
}

