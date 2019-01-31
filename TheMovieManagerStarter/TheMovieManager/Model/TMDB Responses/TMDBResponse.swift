//
//  TMDBResponse.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

struct TMDBResponse: Codable {
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

//now that it conforms to LocalizedError, it conforms to TYPE=ERROR
//We can pass it in as the error to our completion handler
extension TMDBResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage //We'll get message of invalid login, bad api key,etc..
                            //Whatever error messages TMDB spits back at us
    }
}


// Error cast as TMDB Struct
// Error.localized
