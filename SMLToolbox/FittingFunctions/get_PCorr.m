function [X,P,N,C,bErr] = get_PCorr(stimVals,respVals,rval)
% GET_PCORR will calculate the proportion of correct responses for each
% stimulus level.
%
% [X,P,N,C,bErr] = get_PCorr(STIMVALS,RESPVALS)
%
% STIMVALS: A vector/matrix with the stimulus level for each trial.
% RESPVALS: A vector/matrix with the values 0 or 1 indicating if the subject
%           made a correct response for each trial.
% RVAL: (optional) Value for rounding the stimvals.
%
% X: A vector of the unique stimulus levels.
% P: The proportion of correct answers for each stimulus level.
% N: The number correct answers for each stimulus level.
% C: The number trials at each stimulus level.
% bErr: The binomial error for each result.
%
% Created by SML April 2015
% Updated by SML Feb 2017, take matrix inputs and optional rounding of stimvals
% Updated by SML April 2018, included the binomial error calculation.


% Defaults:
if nargin < 3
    rval = [];
end

% Check that inputs match in size:
assert(size(stimVals,1)==size(respVals,1),'The number of entries for each input must be the same!')
assert(size(stimVals,2)==size(respVals,2),'The number of entries for each input must be the same!')

% Round stimulus values if requested:
if ~isempty(rval)
    stimVals = roundToVal(stimVals,rval); 
end

% Get frequency information:
vals_1 = stimVals; vals_1(respVals==0) = NaN;
vals_0 = stimVals; vals_0(respVals==1) = NaN;
[x_1,f_1,~] = freqTable(vals_1);
[x_0,f_0,~] = freqTable(vals_0);

% Calculate output stats:
if isequal(x_1,x_0)
    X = x_1;
    N = f_1;
    C = f_1 + f_0;
else
    X = unique([x_0; x_1]);
    nX = length(X);
    nCol = size(stimVals,2);
    N = NaN([length(X),nCol]);
    C = N;
    for jj = 1:nCol
        for ii = 1:nX
            n = f_1(x_1==X(ii),jj);
            if isempty(n); N(ii,jj) = 0; else N(ii,jj) = n; end
            c = N(ii,jj) + f_0(x_0==X(ii),jj);
            if isempty(c); C(ii,jj) = N(ii,jj); else C(ii,jj) = c; end
        end
    end
end
P = N./C;
bErr = getBinomialErrorBar(P,C,0.3273);

end