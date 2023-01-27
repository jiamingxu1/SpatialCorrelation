%% Shannon's Kalman Filter Tutorial


%% Example 1: Simple Random Walk

% The state transition matrix, relates x_k to x_k+1:
phi_k = 1;

% Covariance matrix for the white noise (a.k.a. walk noise):
Q_k = 1;

% The mapping function between the measurement and state vector:
H_k = 1;

% The measurement variance (rms of 0.5):
R_k = 0.5^2;

% Create a time series and a series of noise corrupted measurements:
t = 0:500;
nSteps = length(t);
x_t = [0 cumsum(normrnd(0,Q_k,[1 nSteps-1]))];
z_t = x_t + normrnd(0,sqrt(R_k),[1 nSteps]);

% Visualise time series and measurements:
figure; hold on
plot(t,x_t,'bo-')
plot(t,z_t,'rx-')

% Priors
x_est = 0; % prior on estimate
P_est = 0; % initial error covariance matrix

all_x_est = zeros(1,nSteps);

for ii = 1:nSteps
    
    % Compute the Kalman gain:
    K = P_est * H_k * inv(H_k * P_est * H_k + R_k);
    
    % Update estimate:
    x_est = x_est + K * (z_t(ii) - H_k * x_est);
    all_x_est(ii) = x_est;
    
    % Update error covariance:
    P_est = (1 - K * H_k) * P_est;
    
    % predict next position:
    x_est = phi_k * x_est;
    
    % predict error covariance:
    P_est = phi_k * P_est * phi_k + Q_k;
    
end

% Plot estimate:
plot(t,all_x_est,'go-')

% Report the RMSE for measurements and kalman filter:
RMSE_measuments = sqrt(sum((z_t - x_t).^2)/nSteps);
disp('The RMSE of the measurements is:')
disp(RMSE_measuments)
RMSE_kalmanFilter = sqrt(sum((all_x_est - x_t).^2)/nSteps);
disp('The RMSE of the Kalman filter is:')
disp(RMSE_kalmanFilter)

% Look, the Kalman filter has a smaller RMSE than simply using the
% measurements alone! This is integration of evidence across time using a
% appropriate weighting function (dependent on known walk variance, Q, and
% measurement variance, R).