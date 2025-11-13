import ProjectDescription

let project = Project(
    name: "Gate",
    organizationName: "m",
    settings: .settings(
        defaultSettings: .recommended
    ),
    targets: [
        .target(
            name: "Gate",
            destinations: [.iPhone, .iPad, .mac],
            product: .framework,
            bundleId: "m.gate",
            sources: [
                "Sources/**"
            ],
            dependencies: [
                .external(name: "RevenueCat"),
                .external(name: "RevenueCatUI")
            ],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "5.0",
                    "IPHONEOS_DEPLOYMENT_TARGET": "26.0"
                ],
                configurations: [
                    .debug(name: "Debug"),
                    .release(name: "Release")
                ],
                defaultSettings: .recommended
            )
        ),
        .target(
            name: "GateTests",
            destinations: [.iPhone, .iPad, .mac],
            product: .unitTests,
            bundleId: "m.gate.tests",
            sources: [
                "Tests/**"
            ],
            dependencies: [
                .target(name: "Gate")
            ]
        )
    ]
)
