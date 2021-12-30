//
//  resampler.h
//  
//
//  Created by Joseph Bellahcen on 12/21/21.
//

#ifndef resampler_h
#define resampler_h

#include <stdlib.h>
#include "sndfile.h"
#include "samplerate.h"

/// Initialize a libsamplerate resampler
static SRC_DATA* __resampler_init__(int target_rate, int sample_rate, int frames, int channels, float *samples) {
    double ratio;
    int src_frames;
    float* src_samples;
    SRC_DATA* resampler;
    
    // Setup
    ratio = (double)target_rate / sample_rate;
    src_frames = frames * ratio;
    src_samples = malloc(sizeof(float) * src_frames * channels);
    
    // Build
    resampler = malloc(sizeof(SRC_DATA));
    resampler->data_in = samples;
    resampler->input_frames = frames;
    resampler->data_out = src_samples;
    resampler->output_frames = src_frames;
    resampler->src_ratio = ratio;
    
    return resampler;
}

#endif /* resampler_h */
