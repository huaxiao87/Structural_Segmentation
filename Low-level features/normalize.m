%% for normalization
% x: input matrix
% y: output matrix with each column vector narmalized by its L2-norm
% pow: normalization L2-norm power, the 21st dimension of
% AudioSpectralFeature Matrix

function [y, pow] = normalize(x)

M = size(x, 1);
N = size(x, 2);

y = zeros(M, N);
pow = zeros(1, N);

for i = 1:N
    power = norm(x(:,i));
    if power ~= 0
    y(:,i) = x(:,i) / power;
    pow(1,i) = power;
    else
        pow(1,i)=0;
    end
end
if pow ~=0
    pow = pow / max(pow);
end



