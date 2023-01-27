function [nloglikelihood] = ll_Cum(parameters, I, m, n, gamma)

% This function calculates the negative log likelihood of observing our 
% data set given a particular choice of parameters for the cumulative normal distribution.
    % Inputs:
        % parameters: a vector containing the parameters of your
        % psychometric function (either [mu, sigma] or [mu, sigma, lambda])
        % I: a vector containing the unique stimulus intensity values
        % m: a vector containing the total number of trials at each stimulus intensity
        % n: a vector containing the number of correct trials at each stimulus 
        % intensity level
        % gamma: guessing rate
    % Output:
        % nlikelihood: the negative log likelihood of the data given the
        % psychometric function and its parameters
        
% Written by EHN

% Check number of inputs and set defaults

if nargin < 4
    error('Not enough input arguments');
end

if nargin < 5
    gamma = 0;
end

if numel(parameters) == 2
    lambda = 10^-5; % Default no lapse rate
else
    lambda = parameters(3);
end

y = gamma+lambda+(1-gamma-2*lambda)*(normcdf(I, parameters(1), parameters(2)));

loglikelihood = log(y)'*n + log(1-y)'*(m-n);
nloglikelihood = -loglikelihood;

end