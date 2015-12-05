function [ Y ] = amplitudeInDecibel( X )
% tranform linear amplitude scale to logarithmic scale(in decibel)

% X: linear scale amplitude vector
z = find(X==0);
X(z) = 0.00001;

Y = 20 * log10(abs(X)/0.00001);
end

