//
//  AudioEditor.swift
//  EZAudio
//
//  Created by Joseph Bellahcen on 12/2/21.
//

import Foundation
import Samplerate
import Resampler

/// The `AudioEditor` modifies `AudioFile` objects
///
/// The `AudioEditor` provides both destructive and non-destructive interfaces for editing, wherein
/// the `AudioFile` object is passed by reference or by value
public class AudioEditor {
    private var audioFile: AudioFile
    
    /// The resulting `AudioFile` after editing
    ///
    /// For destructive `AudioEditor` instances, this will be identical to the `AudioFile` passed during initialization
    public var result: AudioFile {
        return audioFile
    }
    
    /// Initialize a non-destructive `AudioEditor`
    public init(audioFile: AudioFile) {
        self.audioFile = audioFile.copy
    }
    
    /// Initialize a destructive `AudioEditor`
    public init(audioFile: inout AudioFile) {
        self.audioFile = audioFile
    }
    
    /// Converts stereo samples to mono
    public func mixdown() {
        let samples = audioFile.samples
        let channels = audioFile.channels
        let frames = audioFile.frames
        var mono = [Float](repeating: 0, count: frames)
        
        // Average the stereo channels in each frame
        for frame in 0..<frames {
            for channel in 0..<channels {
                mono[frame] += samples[frame * channels + channel]
            }
            
            mono[frame] /= Float(channels)
        }
        
        // Update AudioFile
        audioFile.channels = 1
        audioFile.samples = mono
    }
    
    /// Change `AudioFile` object's sample rate to match the target sample rate using libsamplerate
    public func resample(targetSampleRate: Int) {
        // Initialize SRC_DATA resampler (libsamplerate)
        let resampler = __resampler_init__(Int32(targetSampleRate),
                                           Int32(audioFile.sampleRate),
                                           Int32(audioFile.frames),
                                           Int32(audioFile.channels),
                                           &audioFile.samples)
        
        // Peform resampling and extract new samples
        _ = src_simple(resampler, Int32(SRC_SINC_BEST_QUALITY), Int32(audioFile.channels))
        let outputSize = resampler!.pointee.output_frames * audioFile.channels
        let buffer = UnsafeBufferPointer(start: resampler!.pointee.data_out, count: outputSize)
        let outputSamples = [Float](buffer)
        
        // Cleanup
        buffer.deallocate()
        free(resampler)
        
        // Update AudioFile
        audioFile.sampleRate = targetSampleRate
        audioFile.samples = outputSamples
    }
}
