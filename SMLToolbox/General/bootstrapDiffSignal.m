function [ptLowerBound,ptUpperBound] = bootstrapDiffSignal(X,condVar,iter)
%
%
% Created by SML April 2019

nTrials = length(condVar);
nHigh = sum(condVar==1); 
rDiff = nan(size(X,1),iter);
for ii = 1:iter
   idx = randperm(nTrials);
   iH = idx(1:nHigh);
   iL = idx((nHigh+1):end);
   rDiff(:,ii) = mean(X(:,iL),2) - mean(X(:,iH),2);
end

ptLowerBound = prctile(rDiff',2.5)';
ptUpperBound = prctile(rDiff',97.5)';

end