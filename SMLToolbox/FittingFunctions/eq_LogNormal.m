function [SSE,y] = eq_LogNormal(mu,sigma,x,y)
% EQ_LOGNORMAL:

if nargin < 4
    y = [];
end

fittedCurve = exp((-(log(x/mu)).^2) / (2*sigma^2));

% Get summed squared error if data is supplied:
if isempty(y)
    y = fittedCurve;
    SSE = 0;
else
    fitError = fittedCurve - y;
    SSE = sum(fitError.^2);
end
disp(SSE)
end