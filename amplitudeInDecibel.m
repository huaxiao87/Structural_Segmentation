function [ Y ] = amplitudeInDecibel( X )
% tranform linear amplitude scale to logarithmic scale(in decibel)
Y = 20 * log10(X/0.00001);
end

