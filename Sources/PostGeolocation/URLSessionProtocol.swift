//
//  File.swift
//  
//
//  Created by Galym Anuarbek on 3/20/21.
//

import Foundation

protocol URLSessionProtocol {
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    func pDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol { func resume() }

extension URLSession: URLSessionProtocol {
    internal func pDataTask(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        return dataTask(with: request, completionHandler: completionHandler as (Data?, URLResponse?, Error?) -> Void) as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol { }
