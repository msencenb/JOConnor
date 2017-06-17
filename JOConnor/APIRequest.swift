//
//  APIRequest.swift
//  JOConnor
//
//  Created by Matt Sencenbaugh on 6/16/17.
//  Copyright © 2017 mattsencenbaugh. All rights reserved.
//

import Foundation

protocol Authable: class {
    func authorizationHeader() -> String?
}

enum APIRequestError : Error {
    case initialize
    case parse
    case noData
}

enum APIRequestVerb : String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

struct APIRequest<T: Codable> {
    let absolutePath: String
    let verb: APIRequestVerb
    let decoder = JSONDecoder()
    let postData: PostData?
    let user: Authable?
    
    func initUrl() throws -> URL {
        if let url = URL.init(string: absolutePath) {
            return url
        } else {
            throw APIRequestError.initialize
        }
    }
    
    func jsonRequest(for user: Authable?) throws -> URLRequest {
        let url = try initUrl()
        let request = NSMutableURLRequest.init(url: url)
        request.httpMethod = verb.rawValue
        
        let languages = NSLocale.preferredLanguages.joined(separator: ", ")
        request.setValue(languages, forHTTPHeaderField: "Accept-Language")
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = user?.authorizationHeader() {
            request.setValue(token, forHTTPHeaderField: "Authorization")
        }
        
        return request as URLRequest
    }
    
    func decode(from data: Data) throws -> Decodable {
        return try decoder.decode(T.self, from: data)
    }
}
