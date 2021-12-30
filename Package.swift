// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EZAudio",
    products: [
        .library(
            name: "EZAudio",
            targets: ["EZAudio"]),
    ],
    targets: [
        .target(
            name: "EZAudio",
            dependencies: ["sndfile", "samplerate"]),
        .systemLibrary(name: "sndfile", path: "Sources/lib"),
        .systemLibrary(name: "samplerate", path: "Sources/lib"),
    ]
)
