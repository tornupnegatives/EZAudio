//
//  AudioFile.swift
//  EZAudio
//
//  Created by Joseph Bellahcen on 12/2/21.
//

import Foundation
import Sndfile

/**
 The `AudioFile` class stores and performs basic IO on audio metadata and floating-point samples
 
 `AudioFile` objects thinly wrap the `SF_INFO` struct from libsndfile, making all useful properties of the struct available and editable
 
 - warning: While it is possible to edit `AudioFile` metadata  and samples directly, it is not recommended.
 Please see the `AudioEditor` class, which can safely modify `AudioFile` objects
 */
public class AudioFile {
    private var sf_info: SF_INFO
    private var _samples: [Float]
    
    public var frames: Int {
        get { return Int(sf_info.frames) }
        set { sf_info.frames = sf_count_t(newValue) }
    }
    
    public var sampleRate: Int {
        get { return Int(sf_info.samplerate) }
        set { sf_info.samplerate = Int32(newValue) }
    }
    
    public var channels: Int {
        get { return Int(sf_info.channels) }
        set { sf_info.channels = Int32(newValue) }
    }
    
    public var format: Int {
        return Int(sf_info.format)
    }
    
    var size: Int {
        return _samples.count
    }
    
    public var samples: [Float] {
        get { return _samples }
        set { _samples = newValue }
    }
    
    public var copy: AudioFile {
        return AudioFile(sf_info: sf_info, samples: _samples)
    }
    
    /// Create a new AudioFile using libsndfile
    public init(url: URL) {
        sf_info = SF_INFO()
        _samples = []
        
        // Get audio file metadata using libsndfile
        let sndfile = sf_open(url.path.cString(using: .utf8), Int32(SFM_READ), &sf_info)
        let size = channels * frames
        
        // Import samples using libsndfile
        let samplePtr = UnsafeMutablePointer<Float>.allocate(capacity: size)
        sf_read_float(sndfile, samplePtr, sf_count_t(size))
        
        // Copy samples from pointer and free pointer
        let buffer = UnsafeBufferPointer(start: samplePtr, count: size)
        _samples = [Float](buffer)
        
        // Cleanup
        samplePtr.deallocate()
        sf_close(sndfile)
    }
    
    public init(sf_info: SF_INFO, samples: [Float]) {
        self.sf_info = sf_info
        self._samples = samples
    }
    
    /// Export the `AudioFile` to the disk using the same format as the original file
    public func export(toPath: String) {
        // sf_write_* functions modify sf_info, so make a copy
        var sf_info = sf_info
        let samples = _samples
        let path = toPath.cString(using: .utf8)
        let sndfile = sf_open(path, Int32(SFM_WRITE), &sf_info)
        
        sf_write_float(sndfile, samples, sf_count_t(size))
        sf_close(sndfile)
    }
}
