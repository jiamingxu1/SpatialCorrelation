function [kalmanEst] = getKalmanFilter_dotCloudTracking(X, dotSD, walkSD,inputMode)
%
%
% Created by SML Jan 2017, updated Nov 2018

% Defaults:
if nargin < 4
    inputMode = 'dots';
end

% Dimensions:
switch inputMode
    case 'dots'
        centroids = mean(X,2); % get centroids
        [nFrames, nDots, nTrials] = size(X);
    case 'centroids'
        centroids = X;
        [nFrames, nTrials] = size(X);
end

% Convert standard deviations to variances:
dotVAR = dotSD^2;
walkVAR = walkSD^2;

% Compute Kalman estimates:
kalmanEst = NaN(nFrames,nTrials);
for ii = 1:nTrials
    x_est = 0; % prior on estimate
    P_est = 0; % initial error covariance matrix
    for jj = 1:nFrames
        K = (P_est + walkVAR)/(P_est + walkVAR + dotVAR); % compute the Kalman gain
        x_est = x_est + K * (centroids(jj,ii) - x_est); % update estimate prediction
        kalmanEst(jj,ii) = x_est; % store estimate
        P_est = (1 - K) * P_est; % update error covariance
    end
end

end