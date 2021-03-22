import XCTest
@testable import PostGeolocation

final class PostGeolocationTests: XCTestCase {
    
    var client: PostGeolocation!
    let sessionSuccess = TestURLSession()
    let sessionFail = TestURLSession()
    let sessionNilData = TestURLSession()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func setupRealClient() {
        client = PostGeolocation(session: URLSession.shared)
    }
    
    private func setupFailClient() {
        sessionFail.success = false
        client = PostGeolocation(session: sessionFail)
    }
    
    private func setupSuccessClient() {
        sessionSuccess.success = true
        client = PostGeolocation(session: sessionSuccess)
    }
    
    private func setupNilClient() {
        sessionNilData.success = true
        sessionNilData.isNilData = true
        client = PostGeolocation(session: sessionNilData)
    }
    
    func testGeneral() {
        setupSuccessClient()
        let dataTask = TestURLSessionDataTask()
        sessionSuccess.nextDataTask = dataTask
        
        client.log(api: "https://testurl", lat: 123, lon: 321, time: 11122111, ext: "some ext", callback: { (data, error) in
            let jsonString = try? JSONDecoder().decode(String.self, from: data)
            assert(jsonString != nil)
            assert(jsonString! == "{ \"success\": true }")
            assert(error == nil)
        }, errorHandler: { (error) in
            assert(false) // should not be called
        })

        XCTAssert(dataTask.resumeWasCalled)
    }
    
    func testFail() {
        setupFailClient()
        let dataTask = TestURLSessionDataTask()
        sessionFail.nextDataTask = dataTask
        
        client.log(api: "https://testurl", lat: 123, lon: 321, time: 11122111, ext: "some ext", callback: { (data, error) in
            let jsonString = try? JSONDecoder().decode(String.self, from: data)
            assert(jsonString != nil)
            assert(jsonString! == "{ \"success\": true }")
            assert(error != nil)
        }, errorHandler: { (error) in
            assert(false) // should not be called
        })

        XCTAssert(dataTask.resumeWasCalled)
    }
    
    func testInvalidURL() {
        setupFailClient()
        let dataTask = TestURLSessionDataTask()
        sessionFail.nextDataTask = dataTask
        
        client.log(api: "not valid url", lat: 123, lon: 321, time: 11122111, ext: "some ext", callback: { (data, error) in
            assert(false) // should not be called
        }, errorHandler: { (error) in
            assert(error == .invalidUrl)
        })

        XCTAssert(!dataTask.resumeWasCalled)
    }
    
    func testNilData() {
        setupNilClient()
        let dataTask = TestURLSessionDataTask()
        sessionFail.nextDataTask = dataTask
        
        client.log(api: "https://testurl", lat: 123, lon: 321, time: 11122111, ext: "some ext", callback: { (data, error) in
            assert(false) // should not be called
        }, errorHandler: { (error) in
            assert(error == .nilData)
        })

        XCTAssert(!dataTask.resumeWasCalled)
    }
    
    func testHttbinGeneral() {
        setupRealClient()
        client.log(api: "https://httpbin.org/post", lat: 123, lon: 321, time: 11122111, ext: "some ext", callback: { (data, error) in
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                assert(json["lat"] as? Int == 123)
                assert(json["lon"] as? Int == 321)
                assert(json["time"] as? Int == 11122111)
                assert(json["ext"] as? String == "some ext")
            } else {
                assert(false) // should not be called
            }
        }, errorHandler: { (error) in
            assert(false) // should not be called
        })
    }
    
    func testHttbinNilValues() {
        setupRealClient()
        let logTime = Int64(Date().timeIntervalSince1970)
        client.log(api: "https://httpbin.org/post", callback: { (data, error) in
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                assert(json["lat"] as? Int == 0)
                assert(json["lon"] as? Int == 0)
                assert(json["time"] as? Int64 == logTime)
                assert(json["ext"] as? String == "")
            } else {
                assert(false) // should not be called
            }
        }, errorHandler: { (error) in
            assert(false) // should not be called
        })
    }


    static var allTests = [
        ("testGeneral", testGeneral),
        ("testFail", testFail),
        ("testInvalidURL", testInvalidURL),
        ("testNilData", testNilData),
        ("testHttbinGeneral", testHttbinGeneral),
        ("testHttbinNilValues", testHttbinNilValues)
    ]
}
