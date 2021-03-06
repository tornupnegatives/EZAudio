# EZAudio 🔈

EZAudio is a thin Swift wrapper around `libsndfile` and `libsamplerate`. It provides a simple, cross-platform interface for audio IO without the need to pass around pointers to arcane and mysterious structs

Tested on macOS and Ubuntu

## Dependencies

EZAudio depends on `libsndfile` and `libsamplerate`. On macOS, both can be installed via Hombrew:
```shell
$ brew install libsndfile libsamplerate
```

On Linux:
```shell
$ sudo apt install libsndfile-dev libsamplerate-dev
```

## Usage

### Swift Package Manager
In order to use the library, include this resource as a dependency in Package.swift
```swift
// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name:  "myProject",
  dependencies: [
    .package(url: "https://github.com/tornupnegatives/EZAudio.git", from: "1.0.0"),
  ],
  targets: [
    .target(
      name:"myApplication",
      dependencies:["EZAudio"]),
  ]
)
```

### Example
```swift
import Foundation
import EZAudio

// Import audio file from disk
let url = URL(fileURLWithPath: "/path/to/sound.wav")
var audio = AudioFile(url: url)

// Immutable AudioEditor will create a copy and leave original untouched
var audioEditor = AudioEditor(audioFile: audio)
audioEditor.mixdown()   // Convert to mono
audioEditor.resample(targetSampleRate: 8000)

// Mutable AudioEditor will make destructive edits to original
// var destructiveAudioEditor = AudioEditor(audioFile: &audio)

// Export audio
var result = audioEditor.result
result.export(toPath: "/path/to/new_sound.wav")
```

## Warning ⚠️ 
By default, Xcode will attempt to compile projects as universal binaries. However, due to limitations with `libsndfile`, this behavior must be disabled. This can be done by editing the target configuration such that `General>Architectures>Build Active Architecture Only` is true

This is not necessary when compiling without Xcode, such as with the Swift Package Manager

