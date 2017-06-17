//
//  APIResponse.swift
//  JOConnor
//
//  Created by Matt Sencenbaugh on 6/16/17.
//  Copyright © 2017 mattsencenbaugh. All rights reserved.
//

import Foundation

enum APIResponse {
    case success(decodable: Decodable)
    case failure(readableMessage: String, error: APIError)
}

enum APIError : Error {
    /*  Errors representing non http response errors, or errors produced from the error parameter of nsurlsession is only for client side errors.
        Server errors are represented through the status code of the http response
        see: https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/URLLoadingSystem/NSURLSessionConcepts/NSURLSessionConcepts.html
    */
    case initialization
    case clientSide
    case deserialization
    case reachability
    case noData
    case nonHttp
    
    // Errors for http status codes
    case badRequest // 400
    case unauthorized // 401
    case internalServer // 500
    case serviceUnavailable // 503
    case unknown // general bucket
}
