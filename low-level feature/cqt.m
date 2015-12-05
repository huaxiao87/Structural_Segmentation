function [ cqt ] = cqt( X, fs, B, lowFreq , highFreq)
% fs            sampling rate  
% B             bins per octave
% lowFreq       lowest frequency 
% highFreq      highest frequency

numOfFilters    = log2(highFreq/lowFreq)*B;% how many filters in the filter bank?
cqt             = zeros(numOfFilters,1);% initialization
blockSize       = length(X);% maximum window size

% generate the filter and calculate the coefficients of each basis(filter)
for i = 1:numOfFilters
    step         = 1/fs; % step for sampling
    w            = lowFreq * 2 ^ ((i-1)/B); % center frequency
    windowEnd = floor(blockSize * lowFreq / w)-1;% variable window length
    t            = (0:step:windowEnd*step);% indices for discretizing basis
    filter       = exp(2 * pi * 1j * w * t);% 1j means the imaginary unit
<<<<<<< HEAD:low-level feature/cqt.m
    cqt(i)       = filter * X(1:(windowEnd+1));

=======
    cqt(i)       = filter * X(1:(windowEnd+1),1);
>>>>>>> origin/master:cqt.m
end

end

