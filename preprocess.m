% input              X: the raw audio data, m by 2 matrix (for stereo audio).
% output processedX: the processed X.

function [ processedX ] = preprocess( X )

% some preprocessing steps for audio signal

% downsampling to 11025hz
X = downsample(X,4);

% mix to mono
processedX = mean(X,2);

end

