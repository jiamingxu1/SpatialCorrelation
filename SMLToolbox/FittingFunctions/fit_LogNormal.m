function [params] = fit_LogNormal(X,Y,startLoc)
% FIT_LOGNORMAL fits the log-normal function by minimising sum-squared
% error. The equation is as follows:
%
% exp((-(log(x/a)).^2) / (2*b^2))]
%
% -- INPUTS --
% INDATA: ... 
%
% -- OUTPUTS --
% PARAMS: ...
%
% Adapted from Alais Lab codes by SML Jan 2015

% Minimise SSE:
opt_params = fminsearch(@(x) eq_LogNormal(x(1),x(2),X,Y),startLoc);

params.mu = opt_params(1);
params.sigma = opt_params(2);

end

