function [kalmanEst] = getKalmanFilter(measurement, K)
% 
%
% Created by SML Feb 2017

% Dimensions:
[nFrames, nTrials] = size(measurement);

% Compute Kalman estimates:
kalmanEst = NaN(nFrames,nTrials);
for ii = 1:nTrials 
   x_est = 0; % prior on estimate
   for jj = 1:nFrames
       x_est = x_est + K * (measurement(jj,ii) - x_est); % update estimate prediction
       kalmanEst(jj,ii) = x_est; % store estimate
   end
end
    
end