# PostGeolocation

PostGeolocation is a Swift package created for EQWorks job interview. It allows you to post your geolocation data to a server using HTTPS web protocol. It also includes PostGeolocationManager, which can handle continuously posting your geolocation data for you.

## Usage

PostGeolocation includes shared instance that you can use:

```swift
PostGeolocation.shared
```

When you just start the app, shared instance is nil, so it is only created when you call it. You can also delete the shared instance if needed:

```swift
PostGeolocation.deleteSharedInstance()
```

Here is example usage to log your data one single time using shared instance:

```swift
PostGeolocation.shared.log(
        api: String,
        lat: Double,
        lon: Double,
        time: Int64?,
        ext: String,
        callback: @escaping (Data, Error?) -> Void,
        errorHandler: @escaping (PostGeolocationError) -> Void
    )
```

You can also create your own instance using URLSession:

```swift
PostGeolocation(session: URLSession.shared)
```

If you need to continuously share your data, use PostGeolocationManager. Example:
```swift
let manager = PostGeolocationManager(api: "https://testurl", ext: "some ext")
```
If needed, you can change the api and ext values using setters.

To start continuously logging your data call:
```swift
manager.startUpdatingLocation(every: 5.0)
```

To stop continuously logging your data call:
```swift
manager.stopUpdatingLocation()
```

To log your location only once:
```swift
manager.postCurrentLocation()
```

There are also functions to handle location services:
```swift
manager.checkLocationServicesEnabled()
manager.requestLocationWhenInUse()
manager.requestLocationAlways()
```

Note that when there are no strong references to manager, it will be deleted from the memory.


## Testing

The package already includes both mocked and end-to-end tests. To test use terminal :

```bash
swift test
```

## Test results
```bash
$ swift test
Test Suite 'All tests' started at 2021-03-23 04:57:33.234
Test Suite 'PostGeolocationPackageTests.xctest' started at 2021-03-23 04:57:33.235
Test Suite 'PostGeolocationTests' started at 2021-03-23 04:57:33.235
Test Case '-[PostGeolocationTests.PostGeolocationTests testFail]' started.
Test Case '-[PostGeolocationTests.PostGeolocationTests testFail]' passed (0.067 seconds).
Test Case '-[PostGeolocationTests.PostGeolocationTests testGeneral]' started.
Test Case '-[PostGeolocationTests.PostGeolocationTests testGeneral]' passed (0.000 seconds).
Test Case '-[PostGeolocationTests.PostGeolocationTests testHttbinGeneral]' started.
Test Case '-[PostGeolocationTests.PostGeolocationTests testHttbinGeneral]' passed (0.003 seconds).
Test Case '-[PostGeolocationTests.PostGeolocationTests testHttbinNilValues]' started.
Test Case '-[PostGeolocationTests.PostGeolocationTests testHttbinNilValues]' passed (0.000 seconds).
Test Case '-[PostGeolocationTests.PostGeolocationTests testInvalidURL]' started.
Test Case '-[PostGeolocationTests.PostGeolocationTests testInvalidURL]' passed (0.000 seconds).
Test Case '-[PostGeolocationTests.PostGeolocationTests testNilData]' started.
Test Case '-[PostGeolocationTests.PostGeolocationTests testNilData]' passed (0.000 seconds).
Test Suite 'PostGeolocationTests' passed at 2021-03-23 04:57:33.306.
     Executed 6 tests, with 0 failures (0 unexpected) in 0.071 (0.072) seconds
Test Suite 'PostGeolocationPackageTests.xctest' passed at 2021-03-23 04:57:33.307.
     Executed 6 tests, with 0 failures (0 unexpected) in 0.071 (0.072) seconds
Test Suite 'All tests' passed at 2021-03-23 04:57:33.307.
     Executed 6 tests, with 0 failures (0 unexpected) in 0.071 (0.073) seconds
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
