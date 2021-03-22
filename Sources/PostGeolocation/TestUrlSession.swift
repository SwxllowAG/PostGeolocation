//
//  File.swift
//  
//
//  Created by Galym Anuarbek on 3/20/21.
//

import Foundation

internal class TestURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    func resume() {
        resumeWasCalled = true
    }
}

internal class TestURLSession: URLSessionProtocol {
    var nextDataTask = TestURLSessionDataTask()
    var success = true
    var isNilData = false
    
    var jsonData: Data = {
        let jsonString = "{ \"success\": true }"
        return try! JSONEncoder().encode(jsonString)
    }()
    
    private (set) var lastURL: URL?
    
    func pDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        lastURL = request.url
        let response = success ? successHttpURLResponse(request: request) : wrongHttpURLResponse(request: request, statusCode: 400)
        let error: Error? = success ? nil : NSError(domain: "", code: 400, userInfo: [:])
        let data = isNilData ? nil : jsonData
        completionHandler(data, response, error)
        return nextDataTask
    }
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: nil)!
    }

    func wrongHttpURLResponse(request: URLRequest, statusCode:Int) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: statusCode, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
}
