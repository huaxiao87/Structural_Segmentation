%% Audio spectral envelope [log scale]
%  X: N x 1 vector of downsampled audio signal
%  fs: sampling frequency is 11025Hz
%  windowSize: 3 * beat-length from bpm
%  y: m x n matrix of spectral envelope [m: log frequency bands, n: block number]

function y = SpectralEnvelope(X, fs, windowSize, hopSize, B, lowFreq, highFreq)

% total block number
N = length(X);

% total block number
n = floor((N - windowSize) / hopSize) + 1;

% initialization
% num_band = 64;      % band spacing to 1/8 octave from 62.5Hz to 16kHz
% y = zeros(num_band, n);

for i = 1:n
    iStart = (i-1) * hopSize + 1;
    iEnd = iStart + windowSize -1;
    y(:, i) = cqt(X(iStart:iEnd), fs, B, lowFreq , highFreq);
end

y = amplitudeInDecibel(y);

