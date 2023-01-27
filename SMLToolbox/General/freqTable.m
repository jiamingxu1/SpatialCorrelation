function [x,f,p] = freqTable(X,rval)
% [x,f,p] = freqTable(X,rval) is a function that takes a vector/matrix X, 
% and calculates the frequency and proportion of each unique entry. If 
% binning is required, specify a rounding value with the optional rval 
% input. 
%
% Created by SML Nov 2016
% Updated by SML Feb 2017, handle NaN entries

% Defaults:
if nargin < 2
    rval = [];
end

% Check form of inputs:
assert(isscalar(rval)|isempty(rval),'Ensure rval is a scalar or empty vector.')
if size(X,1) == 1; X = X'; end % transpose X if row vector

% Bin data if requested:
if ~isempty(rval)
   X = roundToVal(X,rval); 
end

% How many bins, entries, columns?
x = unique(X);
x = x(~isnan(x));
nBins = length(x);
[nVals, nCols] = size(X);

% Tally freq and prop for each unique val:
f = NaN(nBins,nCols);
for c = 1:nCols
    for n = 1:nBins
        match = X(:,c) == x(n);
        f(n,c) = sum(match);
    end
end
p = f/nVals;

end