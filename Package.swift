import PackageDescription

let package = Package(
    name: "SessionMiddleware",
    dependencies: [
        .Package(url: "https://github.com/slimane-swift/Middleware.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/noppoMan/Crypto.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/noppoMan/Suv.git", majorVersion: 0, minor: 3)
    ]
)
