// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "VoiceControlTool",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "VoiceControlTool", targets: ["VoiceControlTool"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "VoiceControlTool",
            dependencies: [],
            resources: [.process("Resources")]
        )
    ]
)