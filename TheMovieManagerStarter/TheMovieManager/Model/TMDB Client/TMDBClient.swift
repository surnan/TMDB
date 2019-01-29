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
        static var accountId = 0    //<--- Enter any Int on Queries. Not fully implemented by TMDB yet
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
        case getFavorites
        case search(String)
        case markWatchList
        case markFavorite
        case posterImage(String)
        
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
            case .getFavorites: return Endpoints.base
                + "/account/\(Auth.accountId)/favorite/movies"
                + Endpoints.apiKeyParam
                + "&session_id=\(Auth.sessionId)"
            case .search(let query): return Endpoints.base
                + "/search/movie"
                + Endpoints.apiKeyParam
                + "&query="
                + "\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"  //<--- Query provided because it's associative value
            case .markWatchList: return Endpoints.base
                + "/account/\(Auth.accountId)/watchlist"
                + Endpoints.apiKeyParam
                + "&session_id=\(Auth.sessionId)"
            case .markFavorite: return Endpoints.base
                + "/account/\(Auth.accountId)/favorite"
                + Endpoints.apiKeyParam
                + "&session_id=\(Auth.sessionId)"
            case .posterImage(let path): return "https://image.tmdb.org/t/p/w500"
                + "/\(path)"
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func getPosterImage(path: String, completion: @escaping(Data?, Error?)-> Void){
        let url = Endpoints.posterImage(path).url
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            if let data = data {
                DispatchQueue.main.async {
                    completion(data, nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil, err)
                }
            }
            return
        }.resume()
    }
    
    class func markFavorites(movie: Movie, favorite: Bool, completion: @escaping(Bool, Error?)-> Void){
        let url = Endpoints.markFavorite.url
        let body = MarkFavorite(mediaType: "movie", mediaId: movie.id, favorite: favorite)
        taskForPostRequest(body: body, responseType: TMDBResponse.self, url: url) { (data, err) in
            if let responseObject = data {
            completion(responseObject.statusCode == 1 ||
            responseObject.statusCode == 12 ||
            responseObject.statusCode == 13, err)
            } else {
                completion(false, err)
            }
            return
        }
    }
    
    
    class func markWatchList(movieId: Int, watchlist: Bool, completion: @escaping(Bool, Error?)-> Void){
        let url = Endpoints.markWatchList.url
        let temp = MarkWatchList(mediaType: "movie", mediaId: movieId, watchlist: watchlist)
        taskForPostRequest(body: temp, responseType: TMDBResponse.self, url: url) { (data, error) in
            if let responseObject = data {
                completion(responseObject.statusCode == 1 ||
                    responseObject.statusCode == 12 ||
                    responseObject.statusCode == 13, nil)
            } else {
                completion(false, error)
            }
        }
    }
    

    class func search(query: String, completion: @escaping ([Movie], Error?)-> Void){
        let url = Endpoints.search(query).url
        taskForGetRequest(url: url, type: MovieResults.self) { (data, err) in
            if let responseObject = data {
                completion(responseObject.results, nil)
            } else {
                completion([], err)
            }
            return
        }
    }
    
    
    class func taskForGetRequest<ResponseType:Decodable>(url: URL, type: ResponseType.Type, completion: @escaping (ResponseType?, Error?)-> Void){
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, err)
                }
                return
            }
            do {
//                let temp = try JSONDecoder().decode(type.self, from: data)            //Also works
//                let temp = try JSONDecoder().decode(type.self.self.self, from: data)  //Also works
                let responseObject = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
                return
            } catch {
                print("Data was recived but unable to convert it to desired type\n \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            //  return <-- Failes because the code blocks for do/catch execute AFTER this line.  So we need "return" in EACH block
        }.resume()
    }
    
    class func getFavoritesList(completion: @escaping ([Movie], Error?)-> Void){
        let url = Endpoints.getFavorites.url
        taskForGetRequest(url: url, type: MovieResults.self) { (data, err) in
            if let responseObject  = data {
                completion(responseObject.results, nil)
            } else {
                completion([], nil)
            }
        }
    }
    
    
    
    class func getRequestToken(completion: @escaping (Bool, Error?)-> Void){
        let url = Endpoints.getRequestToken.url
        taskForGetRequest(url: url, type: RequestTokenResponse.self) { (resp, err) in
            if let responseObject = resp {
                Auth.requestToken = responseObject.requestToken
                completion(responseObject.success, nil)
            } else {
                completion(false, err)
            }
            return  //<-- Unlike --> func taskForGetRequest
            //This gets executed AFTER if-else so we only need to add return once to this function
        }
    }
    
    class func getWatchlist(completion: @escaping ([Movie], Error?) -> Void) {
        let url = Endpoints.getWatchlist.url
        taskForGetRequest(url: url, type: MovieResults.self) { (resp, err) in
            if let response = resp {
                completion(response.results, nil)
            } else {
                completion([], err)
            }
            return
        }
    }
    
 
    
    
 
    class func handleLogout(completion: @escaping ()-> Void){
        var request = URLRequest(url: Endpoints.logout.url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "content-mode")
        let _Logout = Logout(sessionId: Auth.sessionId)
        request.httpBody = try! JSONEncoder().encode(_Logout)
        URLSession.shared.dataTask(with: request) { (_, _, _) in
            Auth.requestToken = ""
            Auth.sessionId = ""
        }
        completion()
        return
    }
    
    
    
    class func taskForPostRequest  <RequestType: Encodable, ResponseType: Decodable>(body: RequestType, responseType: ResponseType.Type, url: URL, completion: @escaping(ResponseType?, Error?)-> Void){
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.httpBody = try! JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { (data, resp, err) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, err)
                }
                return
            }
            do{
                let temp = try JSONDecoder().decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(temp, nil)
                }
                return
            } catch {
                print("Error decoding JSON file but we did verify that data has been pulled /n  \(error)")
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
        }.resume()
    }
    
    class func createSessionId(completion: @escaping (Bool, Error?)-> Void){
        let url = Endpoints.createSessionId.url
        let encoding2 = PostSession(requestToken: Auth.requestToken)
        taskForPostRequest(body: encoding2, responseType: SessionResponse.self, url: url) { (response, err) in
            guard let responseObject = response else {
                completion(false, err)
                return
            }
            Auth.sessionId = responseObject.session
            completion(true, nil)
            return
        }
    }
    
    
    class func getLogin(name: String, password: String, completion: @escaping(Bool, Error?)-> Void){
        let url = Endpoints.login.url
        let encodable = LoginRequest(username: name, password: password, requestToken: Auth.requestToken)
        let decodable = LoginResponse.self
        taskForPostRequest(body: encodable, responseType: decodable, url: url) { (response, err) in
            guard let responseObject = response else {
                completion(false, err)
                return
            }
            Auth.requestToken = responseObject.requestToken
            completion(true, nil)
            return
        }
    }
}
