function [params,CIs] = CIs_cumulativeNormal(iter,X,N,C,startLoc,fixedYN)
% CIS_CUMULATIVENORMAL ...
%
% [PARAMS] = CIs_cumulativeNormal(X,N,C,STARTLOC)
%
% ITER: Number of iterations
% X: A vector of the unique stimulus levels.
% N: The number correct answers for each stimulus level.
% C: The number trials at each stimulus level.
% STARTLOC: Starting location for cumulative normal for each parameter.
% FIXEDYN: For each parameter, a 1 or 0 indicating if this parameter is
%          fixed.
%
% Created by SML June 2015

% get fit of the true data:
[params] = fit_cumulativeNormal(X,N,C,startLoc,fixedYN);

% preallocate space for storing bootstrapped parameters:
all_mu = zeros(1,iter);
all_sigma = zeros(1,iter);
all_lambda = zeros(1,iter);

% calculate proportion of trials at each stimulus level:
cumProp = C/sum(C);
% convert to a cumulative value:
cumProp = cumsum(cumProp);

% calculate proportions for the incorrect responses:
respProp = 1 - N./C;

for ii = 1:iter
    
    % random values to be converted into stimulus values and responses:
    fakeVals = rand(sum(C),2);
    
    % Determine stimulus level indexes based on the selected random number 
    % and the cumulative proportions:  
    for jj = 1:length(cumProp)
        fakeVals(fakeVals(:,1)<=cumProp(jj)) = jj + 1;
    end
    
    % response thresholds:
    respThresh = respProp(fakeVals(:,1)-1);
    if size(respThresh,2)>1
        respThresh = respThresh';
    end    
    fakeVals(fakeVals(:,2)<respThresh,2) = 0;
    fakeVals(fakeVals(:,2)>=respThresh,2) = 1;
    
    % convert from index to actual stimulus value:
    fakeVals(:,1) = X(fakeVals(:,1)-1);
    
% tally fake data:
[X_cis,~,N_cis,C_cis] = get_PCorr(fakeVals(:,1),fakeVals(:,2));

[xx] = fit_cumulativeNormal(X_cis,N_cis,C_cis,startLoc,fixedYN);  

all_mu(ii) = xx.mu;
all_sigma(ii) = xx.sigma;
all_lambda(ii) = xx.lambda;

end

CIs.mu = [prctile(all_mu,2.5) prctile(all_mu,97.5)];
CIs.sigma = [prctile(all_sigma,2.5) prctile(all_sigma,97.5)];
CIs.lambda = [prctile(all_lambda,2.5) prctile(all_lambda,97.5)];