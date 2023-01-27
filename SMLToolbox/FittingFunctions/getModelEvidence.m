function logEvidence = getModelEvidence(LL, stepSizes, logPrior)
% This function takes the likelihood function computed using the grid
% method, and marginalises over all dimensions. If a posterior distribution
% is supplied, it will be applied to the likelihood before marginalisation.
% If it is not supplied, a flat prior over the parameter space will be
% assumed. For a
%
% Created by EG May 2018, edits SML August 2018, useful hints from EN!
% Edited by SML Nov 2020: fixed bug in flat prior

% Defaults:
if nargin < 3
    logPrior = [];
end

% Check input:
if isrow(LL) || iscolumn(LL)
    assert(length(stepSizes) == 1, 'Incorrect dimensions')
else
    assert(ndims(LL) == length(stepSizes), 'Incorrect dimensions')
end
assert(all(LL(:) <= 0 | isnan(LL(:))), 'Use log likelihood, not negative')

% Apply prior over parameters:
if ~isempty(logPrior) % supplied prior
    assert(all(size(LL) == size(logPrior)), 'Likelihood and prior do not match in size')
    LL = LL + logPrior;
else % flat prior (v = h * w_x * w_y * ... = 1; so h = 1/(n_x*d_x * n_y*d_y * ...))
    h = 1/(prod(size(LL).*stepSizes));
    LL = LL + log(h);
end

% Marginalise across each paramter dimension:
LL_max = max(LL(:)); % peak of the log-posterior
LL_max0 = LL - LL_max; % shift everything up so peak at 0
LL_max1 = exp(LL_max0); % exponentiate, peak now at 1, min at 0
marginal = LL_max1;
for dim = 1:length(stepSizes) % EACH dimension
    marginal = nansum(marginal, dim) * stepSizes(dim); % marginaliz(/s)e!
end
logEvidence = log(marginal) + LL_max; % shift back!

end
