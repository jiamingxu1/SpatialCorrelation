function [Y,tau] = expSmoothFilter(X,alpha,dT)
% This function takes X as input, which can be a vector or matrix with
% columns treated as separate time series. The parameter alpha is the
% exponential smoothing factor. Y is the output exponentially smoothed time
% series. The time constant tau is also calculated for you based on alpha.
% For this, you need to supply the
%
% Created by SML Sept 2018

% Defaults:
if nargin < 3
    dT = 1;
end

% Checks:
if isrow(X); X = X'; end % transpose to column vector if row vector

% Smooth X:
Y = nan(size(X)); % pre-allocate
Y(1,:) = X(1,:); % y_0 = x_0
nCalc = size(X,1);
for ii = 2:nCalc
    Y(ii,:) = alpha * X(ii,:) + (1 - alpha) * Y(ii-1,:);
end

% Compute tau:
tau = -dT/log(1-alpha);

end