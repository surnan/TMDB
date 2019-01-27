//
//  TMDBClient.swift
//  TheMovieManager
//
//  Created by Owen LaRosa on 8/13/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation

class TMDBClient {
    
    static let apiKey = "d6dff50ddfca06c2f90832ec086183fc"
    
    struct Auth {
        static var accountId = 0
        static var requestToken = ""
        static var sessionId = ""
    }
    
    enum Endpoints {
        static let base = "https://api.themoviedb.org/3"
        static let apiKeyParam = "?api_key=\(TMDBClient.apiKey)"
        
        case getWatchlist
        case getRequestToken
        case login
        case createSessionId
        case webAuth
        case logout
        
        var stringValue: String {
            switch self {
            case .getWatchlist: return Endpoints.base
                + "/account/\(Auth.accountId)/watchlist/movies"
                + Endpoints.apiKeyParam
                + "&session_id=\(Auth.sessionId)"
            case .getRequestToken: return Endpoints.base
                + "/authentication/token/new"
                + Endpoints.apiKeyParam
            case .login: return Endpoints.base
                + "/authentication/token/validate_with_login"
                + Endpoints.apiKeyParam
            case .createSessionId: return Endpoints.base
                + "/authentication/session/new"
                + Endpoints.apiKeyParam
            case .webAuth: return "https://www.themoviedb.org/authenticate/"
                + Auth.requestToken
                + "?redirect_to=themoviemanager:authenticate"
                //Before Colon = protocol.  Here it's a url to be handled by "themoviemanager"
                //After Colon = path
            case .logout: return Endpoints.base
                + "/authentication/session"
                + Endpoints.apiKeyParam
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    

    class func handleLogout(completion: @escaping ()-> Void){
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "content-mode")
        
        let _Logout = Logout(sessionId: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(_Logout)
        URLSession.shared.dataTask(with: request).resume()
        completion()
        return
    }
    
    
    class func createSessionId(completion: @escaping (Bool, Error?)-> Void){
        var request = URLRequest(url: Endpoints.createSessionId.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        let _PostSession = PostSession(requestToken: Auth.requestToken)

        
        request.httpBody = try! JSONEncoder().encode(_PostSession)
        
        URLSession.shared.dataTask(with: request) { (data, resp, err) in
            guard let data = data else {
                completion(false, err)
                return
            }
            do {
                let __PostSession2 = try JSONDecoder().decode(SessionResponse.self, from: data)
                Auth.sessionId = __PostSession2.session
                completion(true, nil)
                return
            } catch {
                print("1 - Unable to convert data to valid LoginRequest struct \n Or invalid Login credentials \(error.localizedDescription)")
                completion(false, error)
            }
            }.resume()
    }
    
    
    class func getLogin(name: String, password: String, completion: @escaping(Bool, Error?)-> Void){
        var request = URLRequest(url: Endpoints.login.url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        
        let _LoginRequest = LoginRequest(username: name, password: password, requestToken: Auth.requestToken)
        request.httpBody = try! JSONEncoder().encode(_LoginRequest.self)
        
        URLSession.shared.dataTask(with: request) { (data, resp, err) in
            guard let data = data else {
                completion(false, err)
                return
            }
            do {
                let _LoginRequest2 = try JSONDecoder().decode(LoginResponse.self, from: data)
                Auth.requestToken = _LoginRequest2.requestToken
                completion(true, nil)
                return
            } catch {
                print("2 - Unable to convert data to valid LoginRequest struct \n Or invalid Login credentials \(error.localizedDescription)")
                completion(false, error)
            }
            }.resume()
    }
    
    
    class func getRequestToken(completion: @escaping (Bool, Error?)-> Void){
        let url = Endpoints.getRequestToken.url
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data else {
                completion(false, err)
                return
            }
            do {
            let _RequestTokenResponse = try JSONDecoder().decode(RequestTokenResponse.self, from: data)
                Auth.requestToken = _RequestTokenResponse.requestToken
                print("Auth.requestToken = \(Auth.requestToken)")
                completion(true, nil)
                return
            } catch {
                print("Unable to obtain request token with API Key --> \(error.localizedDescription)")
                completion(false, error)
                return
            }
        }.resume()
    }
    
    
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: Endpoints.getWatchlist.url) { data, response, error in
            guard let data = data else {
                completion([], error)
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(MovieResults.self, from: data)
                completion(responseObject.results, nil)
            } catch {
                completion([], error)
            }
        }
        task.resume()
    }
    
}
