import Foundation
import CoreLocation

protocol PostGeolocationManagerDelegate {
    func didPostGeolocation(lat: Double, lon: Double, responseData: Data)
    func didFailToPostGeolocation(lat: Double, lon: Double, responseError: PostGeolocationError)
}

class PostGeolocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager: CLLocationManager
    private var timer: Timer?
    private var postGeolocation: PostGeolocation
    private(set) var api: String
    private(set) var ext: String
    
    var delegate: PostGeolocationManagerDelegate?
    
    init(api: String, ext: String = "") {
        self.api = api
        self.ext = ext
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        postGeolocation = PostGeolocation(session: URLSession.shared)
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
        locationManager.stopUpdatingLocation()
    }
    
    // MARK: public functions
    
    /*
     *  setApi
     *
     *  Discussion:
     *      Updates api value.
     */
    func setApi(_ newValue: String) {
        self.api = newValue
    }
    
    /*
     *  setExt
     *
     *  Discussion:
     *      Updates ext value.
     */
    func setExt(_ newValue: String) {
        self.ext = newValue
    }
    
    /*
     *  startUpdatingLocation
     *
     *  Discussion:
     *      Posts current location every "timeInterval" seconds. Posts (0, 0) location if no location service enabled.
     */
    func startUpdatingLocation(every timeInterval: Double) {
        timer?.invalidate()
        timer = nil
        timer = Timer(timeInterval: timeInterval, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: true)
    }
    
    /*
     *  stopUpdatingLocation
     *
     *  Discussion:
     *      Stops posting current location.
     */
    func stopUpdatingLocation() {
        timer?.invalidate()
        timer = nil
    }
    
    /*
     *  postCurrentLocation
     *
     *  Discussion:
     *      Posts current location only once. Posts (0, 0) location if no location service enabled.
     */
    func postCurrentLocation() {
        if checkLocationServicesEnabled() {
            if #available(OSX 10.14, *) {
                locationManager.requestLocation()
            } else {
                // Fallback on earlier versions
            }
        } else {
            postGeolocation.log(api: self.api, lat: 0, lon: 0, ext: ext, callback: { data, error in
                self.delegate?.didPostGeolocation(lat: 0, lon: 0, responseData: data)
            }, errorHandler: { error in
                self.delegate?.didFailToPostGeolocation(lat: 0, lon: 0, responseError: error)
            })
        }
    }
    
    /*
     *  checkLocationServicesEnabled
     *
     *  Discussion:
     *      Returns true iff location services are enabled.
     */
    func checkLocationServicesEnabled() -> Bool {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .notDetermined, .restricted, .denied:
                    return false
                case .authorizedAlways, .authorizedWhenInUse:
                    return true
                @unknown default:
                    return false
            }
        } else {
            return false
        }
    }
    
    /*
     *  requestLocationWhenInUse
     *
     *  Discussion:
     *      Requests location when in use authorization.
     */
    func requestLocationWhenInUse() {
        if #available(OSX 10.15, *) {
            locationManager.requestWhenInUseAuthorization()
        } else {
            // Fallback on earlier versions
        }
    }
    
    /*
     *  requestLocationAlways
     *
     *  Discussion:
     *      Requests location always authorization.
     */
    func requestLocationAlways() {
        if #available(OSX 10.15, *) {
            locationManager.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        let coor = lastLocation.coordinate
        postGeolocation.log(api: self.api, lat: coor.latitude, lon: coor.longitude, ext: ext, callback: { data, error in
            self.delegate?.didPostGeolocation(lat: coor.latitude, lon: coor.longitude, responseData: data)
        }, errorHandler: { error in
            self.delegate?.didFailToPostGeolocation(lat: coor.latitude, lon: coor.longitude, responseError: error)
        })
    }
    
    // MARK: private helpers
    
    @objc private func handleTimer() {
        postCurrentLocation()
    }
}
