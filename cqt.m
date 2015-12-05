function [ cqt ] = cqt( X , blockSize )
fs              = 11025;
B               = 8;
lowFre          = 62.5;
highFre         = 16000;
numOfFilters    = log2(highFre/lowFre)*8;% how many filters in the filter bank?
cqt             = zeros(numOfFilters,1);
% generate the filter bank
for i = 1:numOfFilters
    step         = 1/fs; % step for sampling
    w            = lowFre * 2 ^ ((i-1)/B); % center frequency
    windowEnd = floor(blockSize * lowFre / w)-1;% window length
    t            = (0:step:windowEnd*step);
    filter       = exp(2 * pi * j * w * t);
    cqt(i)       = filter * X(1:(windowEnd+1))';
end

end

