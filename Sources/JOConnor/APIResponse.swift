//
//  APIResponse.swift
//  JOConnor
//
//  Created by Matt Sencenbaugh on 6/16/17.
//  Copyright © 2017 mattsencenbaugh. All rights reserved.
//

import Foundation

public enum APIResponse {
    case success(decodable: Decodable, rawResponse: HTTPURLResponse)
    case failure(readableMessage: String, error: APIError, data: Data?)
}

public enum APIError : Error {
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
    case unauthenticated // 401
    case unauthorized // 403
    case unprocessable // 422
    case internalServer // 500
    case serviceUnavailable // 503
    case unknown // general bucket
}
