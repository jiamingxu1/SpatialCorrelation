% Calculates the estimated remaining time based on the elapsed time and how
% far along we are. Outputs the time in [hours minutes seconds]. Inputs are
% the current position and the total steps, respectively. Make sure to call
% TIC before this function, but outside of your loop so that it does not
% reset each iteration.
% 
% Usage:
%   t = CalculateTimeRemaining(n, N)
% 
% EG Gaffin-Cahn
% 4/2015
% 

function t = CalculateTimeRemaining(n, N)

dt = toc; % elapsed time
T = dt * N / n; % total time
rt = T - dt; % remaining time
t = [0 0 0]; % initialize output remaining time: [hours minutes seconds]

hr = 3600;
min = 60;

if rt > hr % hours remaining
    t(1) = floor(rt / hr);
    rt = rt - hr*t(1);
end
if rt > min % minutes remaining
    t(2) = floor(rt / min);
    rt = rt - min*t(2);
end
t(3) = round(rt); % seconds remaining