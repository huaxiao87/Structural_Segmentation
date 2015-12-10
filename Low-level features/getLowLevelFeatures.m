%% Main
function [featureMatrix,bpm] = getLowLevelFeatures(filePath)
% global constant parameters
fs = 11025;     % each audio file downsample to 11025Hz;

% CQT parameters
B               = 8;        % bins per octave
lowFreq          = 62.5;     % lowest frequency band
highFreq         = 16000;      % highest frequency band

% read audio files
[x, fs0] = audioread(filePath);

% mix channel
X = mean(x,2);

% downsampling
X = downsample(X, fs0/fs);       % fs = 44100, n = 44100/11025 = 4

% Bpm (code from labrosa)
t = tempo2(X, fs);
bpm = t(2);       % use faster BPM estimate

% windowsize & hopsize
hopSize = round(fs * 60 / bpm);      % hop size equal to beat length
windowSize = 3 * hopSize;

% low-level Feature Matrix using constant Q transform[CQT] 
spectral_envelope                   = SpectralEnvelope(X, fs, windowSize, hopSize, B, lowFreq, highFreq);
[spectrum, power]                   = normalize(spectral_envelope);

% using principal component analysis to reduce the number of features
[~,spectrumProjection]   = pca(spectrum');

% we only use the first 20 principal components
spectrumProjection                  = spectrumProjection(:,1:20);

% append the norm to the feature matrix
featureMatrix = [spectrumProjection';power]';





