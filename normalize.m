%% for normalization

function [y, pow] = normalize(x)

M = size(x, 1);
N = size(x, 2);

y = zeros(M, N);
pow = zeros(M, 1);

for i = 1:N
    power = norm(x(:,i));
    y(:,i) = x(:,i) / power;
    pow(1,i) = power;
end

pow = pow / max(pow);



