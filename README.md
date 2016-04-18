# SessionMiddleware

Session Middleware for Slimane


## Usage
```swift
import Slimane
import SessionMiddleware

let app = Slimane()

// SessionConfig
let sesConf = SessionConfig(
    secret: "my-secret-value",
    expires: 180,
    HTTPOnly: true
)

// Enable to use session in Slimane
app.use(SessionMiddleware(conf: sesConf))
```

## Apis

### SessionMiddleware

Middleware for session handling in Slimane

```swift
SessionMiddleware(conf: SessionConfig)
```

### SessionConfig

Session Configuration Struct.

#### Members
* store: SessionStoreType
  - Default store is the SessionMemoryStore
* keyName: String
* secret: String
  - Your application secret value
* expires: Int?
  - Sec for cookie/stored data ttl
* HTTPOnly: Bool
* secure: Bool
* maxAge: Int?
* domain: String?
* path: String?


### SessionStoreType

```swift
public protocol SessionStoreType {
    func destroy(sessionId: String)
    func load(sessionId: String, completion: (SessionResult<[String: AnyObject?]>) -> Void)
    func store(sessionId: String, values: [String: AnyObject?], expires: Int?, completion: () -> Void)
}
```

### SessionMemoryStore

SessionMemoryStore is default store for SessionMiddleware.
And this is not recommended to use under production  environment.

### SerializerType

Protocol for Serializer

```swift
public protocol SerializerType {
    func serialize(src: [String: AnyObject]) throws -> String
    func deserialize(src: String) throws -> [String: AnyObject]
}
```

### JsonSerializer

Serialize/deserialize the value with JSON format

```swift
let serializer = JsonSerializer()

let serialized = serializer.serializer(["foo": "bar"])

print(serializer.deserialize(serialized))
```

## Create your own SessionStore

Easy to make an own SessionStore with confirming SessionStoreType. Here is an easy FileSessionStore Example.

```swift
import SessionMiddleware
import Suv

struct FileSessionStore: SessionStoreType {
    func destroy(sessionId: String) {
        FS.unlink("/path/to/\(sessionId).json")
    }

    func load(sessionId: String, completion: (SessionResult<[String: AnyObject?]>) -> Void) {
        let serializer = JsonSerializer()
        FS.readFile("/path/to/\(sessionId).json") {
            if case .Data(let buf) = $0 {
                let dictionary = serializer.deserialize(buf.toString()!)
                completion(.Success(dictionary))
            }

            if case .Error(let error) = $0 {
                completion(.Error(error))
            }
        }
    }

    func store(sessionId: String, values: [String: AnyObject?], expires: Int?, completion: () -> Void) {
        let serializer = JsonSerializer()
        // Overwrite
        FS.writeFile("/path/to/\(sessionId).json", Buffer(try! serializer(values))) { _ in
          completion()
        }
    }
}
```

## List of available SessionStores
* SessionMemoryStore(Including this package)
* [SessionRedisStore](https://github.com/slimane-swift/SessionRedisStore)


## Package.swift
```swift
import PackageDescription

let package = Package(
    name: "SlimaneApp",
    dependencies: [
        .Package(url: "https://github.com/slimane-swift/SessionMiddleware.git", majorVersion: 0, minor: 1)
    ]
)
```
## Licence

SessionMiddleware is released under the MIT license. See LICENSE for details.
