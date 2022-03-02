// swift-tools-version:5.5
import PackageDescription

let isLocalDevMode = false

var dependencies: [Package.Dependency] = [
    .package(url: "https://github.com/vapor/fluent-sqlite-driver", from: "4.0.0"),
    .package(url: "https://github.com/binarybirds/liquid-local-driver", from: "1.3.0"),
]

if isLocalDevMode {
    dependencies += [
        .package(path: "../feather-core"),
        .package(path: "../analytics-module"),
        .package(path: "../aggregator-module"),
        .package(path: "../blog-module"),
        .package(path: "../markdown-module"),
        .package(path: "../redirect-module"),
        .package(path: "../swifty-module"),
    ]
}
else {
    dependencies += [
        .package(url: "https://github.com/feathercms/feather-core", .revision("a54c9323416e5a45f7a2d9b4ee601444ff04f154")),
//        .package(url: "https://github.com/colly-digital/analytics-module", .branch("colly")),
//        .package(url: "https://github.com/colly-digital/aggregator-module", .branch("colly")),
        .package(url: "https://github.com/colly-digital/blog-module", .branch("colly")),
        .package(url: "https://github.com/colly-digital/markdown-module", .branch("colly")),
//        .package(url: "https://github.com/colly-digital/redirect-module", .branch("colly")),
        .package(url: "https://github.com/colly-digital/swifty-module", .branch("colly")),
    ]
}

let package = Package(
    name: "feather",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        .executable(name: "Feather", targets: ["Feather"]),
    ],
    dependencies: dependencies,
    targets: [
        .executableTarget(name: "Feather", dependencies: [
            .product(name: "FeatherCore", package: "feather-core"),
            .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
            .product(name: "LiquidLocalDriver", package: "liquid-local-driver"),
//            .product(name: "AnalyticsModule", package: "analytics-module"),
//            .product(name: "AggregatorModule", package: "aggregator-module"),
            .product(name: "BlogModule", package: "blog-module"),
//            .product(name: "RedirectModule", package: "redirect-module"),
            .product(name: "SwiftyModule", package: "swifty-module"),
            .product(name: "MarkdownModule", package: "markdown-module"),
        ], exclude: [
            "Modules/README.md",
        ], swiftSettings: [
            .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
        ]),
//        .testTarget(name: "FeatherTests", dependencies: [
//            .target(name: "Feather"),
//            .product(name: "FeatherTest", package: "feather-core")
//        ])
    ]
)
