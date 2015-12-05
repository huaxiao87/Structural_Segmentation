% Main 
fs = 11025;     % each audio file downsample to 11025Hz;

[x, fs0] = audioread('test.m4a');

% mix channel
X = mean(x,2);

% downsampling
X = downsample(X, 4);       % fs = 44100, n = 44100/11025 = 4

% Bpm (code from labrosa)
t = tempo2(X, fs);
bpm = t(2);       % use faster BPM estimate

% windowsize & hopsize
hopSize = round(fs * 60 / bpm);      % hop size equal to beat length
windowSize = 3 * hopSize;



