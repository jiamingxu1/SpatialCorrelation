function [params] = fit_Weibull(X,N,C,startLoc,fixedYN)
% FIT_CUMULATIVENORMAL ...
%
% [PARAMS] = fit_cumulativeNormal(X,N,C,STARTLOC)
%
% X: A vector of the unique stimulus levels.
% N: The number correct answers for each stimulus level.
% C: The number trials at each stimulus level.
% STARTLOC: Starting location for cumulative normal for each parameter.
% FIXEDYN: For each parameter, a 1 or 0 indicating if this parameter is
%          fixed.
%
% Created by SML April 2015

if nargin < 5
    fixedYN = [0 0 0];
end

% Minimise negative log likelihood:
opt_params = [];

if fixedYN == [0 0 0]
    opt_params = fminsearch(@(x) nll_cumulativeNormal(x(1),x(2),x(3),X,N,C),startLoc);
    params.mu = opt_params(1);
    params.sigma = opt_params(2);
    params.lambda = opt_params(3);
elseif fixedYN == [0 0 1]
    aa = startLoc(3);
    startLoc(3) = [];
    opt_params = fminsearch(@(x) nll_cumulativeNormal(x(1),x(2),aa,X,N,C),startLoc);
    params.mu = opt_params(1);
    params.sigma = opt_params(2);
    params.lambda = aa;
elseif fixedYN == [0 1 1]
    aa = startLoc(2);
    bb = startLoc(3);
    startLoc(2:3) = [];
    opt_params = fminsearch(@(x) nll_cumulativeNormal(x(1),aa,bb,X,N,C),startLoc);
    params.mu = opt_params(1);
    params.sigma = aa;
    params.lambda = bb;
elseif fixedYN == [1 0 1]
    aa = startLoc(1);
    bb = startLoc(3);
    startLoc(2:3) = [];
    opt_params = fminsearch(@(x) nll_cumulativeNormal(aa,x(1),bb,X,N,C),startLoc);
    params.mu = aa;
    params.sigma = opt_params(1);
    params.lambda = bb;
end

assert(~isempty(opt_params),'Add a case for your specific fixedYN vector.')

end

function [nll] = nll_cumulativeNormal(X_alpha,X_beta,X_lambda,X_gamma,X,N,C)

nX = length(X);

% Psychometric function:
PF = X-gamma (1 - X_gamma - X_lambda) * (1 - exp(-(X/X_alpha)^X_beta));

% Adjustment to prevent Inf and NaN:
if any(PF==0)
    PF(PF==0) = 1/C;
end
if any(PF==1)
    PF(PF==1) = (T-1)/C;
end

% Get log likelihood:
LH = zeros(size(X));
for ii = 1:nX
    LH(ii) = N(ii)*log(PF(ii)) + (C(ii)-N(ii))*log(1-PF(ii));
end

% Negative log likelihood:
nll = -sum(LH);

end