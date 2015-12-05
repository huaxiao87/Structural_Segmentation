%% Main
% global constant parameters
fs = 11025;     % each audio file downsample to 11025Hz;

% CQT parameters
B               = 8;        % bins per octave
lowFreq          = 62.5;     % lowest frequency band
highFreq         = 16000;      % highest frequency band
numOfFilters    = log2(highFreq/lowFreq) * B;     % how many filters in the filter bank

% run through files

% read audio files
[x, fs0] = audioread('test.m4a');

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
spectral_envelope = SpectralEnvelope(X, fs, windowSize, hopSize);
[spectrum, power] = normalize(sepctral_envelope);

% norm need normed!!


