function [peak_pt,peak_r] = getPeakCrossCorrelation(X,Y,fs,truncateBy)
%
%
% Created by SML Feb 2017

% defaults:
if nargin < 4
    truncateBy = round(0.1*length(X));
end

% Calculate Correlation Coefficient:
[r,lag] = slidingCrossCorrelationCoefficient(X,Y,truncateBy);

% Convert from vector index to time value:
lag = (1/fs) * lag;

% Find peak correlation:
peak_pt = lag(r==max(r));
peak_r = r(r==max(r));

subplot(1,2,1); hold on; xlabel('Frame'); ylabel('Velocity'); plot(X); plot(Y,'r')
subplot(1,2,2); hold on; xlabel('Lag (sec)'); ylabel('Correlation'); plot(lag,r);

end