function [ Y ] = amplitudeInDecibel( X )
% tranform linear amplitude scale to logarithmic scale(in decibel)

% X: linear scale amplitude vector

Y = 20 * log10(abs(X)/0.00001);
end

