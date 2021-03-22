import Foundation
import Network

public enum PostGeolocationError {
    case invalidUrl
    case jsonSerialization
    case nilData
    case noLocation
}

public class PostGeolocation {
    
    private static var sharedInstrance: PostGeolocation?
    
    static var shared: PostGeolocation {
        guard let shared = sharedInstrance else {
            sharedInstrance = PostGeolocation(session: URLSession.shared)
            return sharedInstrance!
        }
        return shared
    }
    
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol) {
        self.session = session
    }
    
    static func deleteSharedInstance() {
        sharedInstrance = nil
    }
    
    func log(
        api: String,
        lat: Double = 0,
        lon: Double = 0,
        time: Int64? = nil, // epoch timestamp in seconds
        ext: String = "", // extra text payload
        callback: @escaping (Data, Error?) -> Void,
        errorHandler: @escaping (PostGeolocationError) -> Void
    ) {
        let time = time ?? Int64(Date().timeIntervalSince1970)
        
        let payload: [String: Any] = [
            "lat": lat,
            "lon": lon,
            "time": time,
            "ext": ext,
        ]
        
        guard let url = URL(string: api) else {
            errorHandler(.invalidUrl)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            errorHandler(.jsonSerialization)
            return
        }
        request.httpBody = httpBody
        session.pDataTask(with: request) { (data, response, error) in
            if let data = data {
                callback(data, error)
            } else {
                errorHandler(.nilData)
            }
        }.resume()
    }
}
