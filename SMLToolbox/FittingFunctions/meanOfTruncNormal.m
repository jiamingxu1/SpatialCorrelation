function [meanVal] = meanOfTruncNormal(mu,sigma,bounds)
% This function analytically calculates the mean of a truncated normal
% distribution. Inputs are the mean (mu) and standard deviation (sigma) of
% the normal distribution. The untruncated ranged of the distribution is
% given by the bounds parameter, a vector of length 2, specifing the lower
% bound (element 1) and the upper bound (element 2). Output is the mean.
%
% Created by SML July 2019
% Updated by SML Oct 2019 to handle vector input

alpha = (bounds(:,1) - mu) ./ sigma;
beta = (bounds(:,2) - mu) ./ sigma;
meanVal = mu + sigma .* ((normpdf(alpha) - normpdf(beta))./(normcdf(beta) - normcdf(alpha)));

end