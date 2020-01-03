//
//  APIServer.swift
//  JOConnor
//
//  Created by Matt Sencenbaugh on 6/16/17.
//  Copyright © 2017 mattsencenbaugh. All rights reserved.
//

import Foundation

open class APIServer {
    let encoder = JSONEncoder()
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    public init() {
        encoder.dateEncodingStrategy = .iso8601
    }
    
    public static let sharedInstance: APIServer = {
        let instance = APIServer()
        return instance
    }()
    
    public func sendRequest<T>(_ request: APIRequest<T>, completion: @escaping ((APIResponse) -> Void)) {
        do {
            let task = try getTaskForRequest(request, completionHandler: { (data, urlResponse, error) -> Void in
                // This error represents an error tossed back by nsurlsession itself (before it hits the server)
                guard error == nil else {
                    let error = error!
                    print("Errored out with \(error)")
                    let response = APIResponse.failure(readableMessage: "Something went wrong before sending your request", error: APIError.clientSide)
                    self.fireCompletionOnMainThread(response: response, completion: completion)
                    return
                }
                
                // TODO do head :ok responses return data? Or would that throw this?
                guard let data = data else {
                    let response = APIResponse.failure(readableMessage: "No data sent back", error: APIError.noData)
                    self.fireCompletionOnMainThread(response: response, completion: completion)
                    return
                }
                
                // We are only able to parse this if we can do so as an httpurlresponse to read status codes properly
                guard let urlResponse = urlResponse as? HTTPURLResponse else {
                    let response = APIResponse.failure(readableMessage: "Non http response received", error: APIError.nonHttp)
                    self.fireCompletionOnMainThread(response: response, completion: completion)
                    return
                }
                
                let response = self.parseUrlResponse(response: urlResponse, data: data, request: request)
                self.fireCompletionOnMainThread(response: response, completion: completion)
            })
            
            task.resume()
        } catch APIRequestError.initialize {
            print("Failed initialization")
            completion(APIResponse.failure(readableMessage: "Please try again later", error: APIError.initialization))
        } catch {
            print("Encoding probably failed")
            completion(APIResponse.failure(readableMessage: "Please try again later", error: APIError.initialization))
        }
    }
    
    private func getTaskForRequest<T>(_ request: APIRequest<T>, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) throws -> URLSessionTask {
        let urlRequest = try request.jsonRequest(for: request.user)
        
        switch request.verb {
        case .get, .delete:
            return session.dataTask(with: urlRequest, completionHandler: completionHandler)
        case .post, .put:
            guard let postData = request.postData else {
                throw APIError.noData
            }
            
            let params = try encoder.encode(postData)
            return session.uploadTask(with: urlRequest, from: params, completionHandler: completionHandler)
        }
    }
    
    private func parseUrlResponse<T>(response: HTTPURLResponse, data: Data, request: APIRequest<T>) -> APIResponse {
        switch response.statusCode {
        case 200, 201:
            do {
                let decodedT = try request.decode(from: data)
                return APIResponse.success(decodable: decodedT, rawResponse: response)
            } catch {
                print("\(error)")
                return APIResponse.failure(readableMessage: "We are having issues communicating with the server, please try again later", error: APIError.deserialization)
            }
        case 204:
            return APIResponse.success(decodable: "", rawResponse: response)
        case 400:
            return APIResponse.failure(readableMessage: "Request rejected by the server.", error: APIError.badRequest)
        case 401:
            return APIResponse.failure(readableMessage: "Your credentials are not valid. Please double check that you have entered your info in correctly and try again.", error: APIError.unauthorized)
        case 500:
            return APIResponse.failure(readableMessage: "Internal server error occured, please try again later.", error: APIError.internalServer)
        case 503:
            return APIResponse.failure(readableMessage: "We are temporarily unable to handle your request. Please try again later.", error: APIError.serviceUnavailable)
        default:
            return APIResponse.failure(readableMessage: "Unknown error", error: APIError.unknown)
        }
    }
    
    private func fireCompletionOnMainThread(response: APIResponse, completion: @escaping ((APIResponse) -> Void)) -> Void {
        DispatchQueue.main.async(execute: { completion(response) })
    }
}
