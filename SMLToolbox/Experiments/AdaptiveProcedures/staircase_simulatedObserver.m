function [X,P] = staircase_simulatedObserver()
% STAIRCASE_SIMULATEDOBSERVER is a code to check a staircase function is
% working properly.
%
% [...] = staircase_simulatedObserver(...)
%
% X: the input 2D matrix or vector.
% DIM: specifies if rows or columns are to be shuffled (optional, default rows).
% SPECRANGE: is the specific rows/columns to be shuffled (optional, default all).
%
% Created by SML April 2015

all_stim = [];
all_resp = [];
all_thresh = [];
all_pThresh = [];
all_mu = [];
all_sigma = [];

trials = 50;
stepSize = 1;
refVal = 10;
start_stimVals = [5 15];

mu = refVal;
sigma = 1.75;
xVals = 5:0.05:15;
yVals = normcdf(xVals,mu,sigma);
yVals(yVals<0.5) = 1 - yVals(yVals<0.5); % folded

for kk = 1:100

figure; hold on
nStaircases = 4;
for jj = 1:nStaircases % EACH STAIRCASE
    
if jj <= nStaircases/2
    stimVals = start_stimVals(1);
else
    stimVals = start_stimVals(2);
end
respVals = 1;
    
    for ii = 1:trials % EACH TRIAL

        nextVal = staircase_1up2down_crisscross(refVal,stimVals,respVals,stepSize);
        stimVals(end+1) = nextVal;
        
        pcorr = yVals(xVals == nextVal);
        resp = rand;
        if pcorr >= resp
            respVals(end+1) = 1;
        elseif pcorr < resp
            respVals(end+1) = 0;
        end
        
        if length(stimVals)~=length(respVals)
            assert(length(stimVals)==length(respVals),'Must have same number of entries for stimulus and response vectors!')
        end
        
    end

    all_stim = [all_stim stimVals];
    all_resp = [all_resp respVals];
    
    plot(stimVals,'-k')
    disp([stimVals' respVals'])
    
%     nLastTrials = 20;
%     thresh = mean(stimVals(end-nLastTrials:end));
%     all_thresh(end+1) = thresh;
%     pThresh = 0.5 + 0.5 * (1 - exp(-(thresh/aVal)^bVal));
%     all_pThresh(end+1) = pThresh;
    
end

% figure; hist(all_thresh,10)
% figure; hist(all_pThresh,10)

[X,P,N,C] = get_PCorr(all_stim,all_resp);

plotYN = 0;
if plotYN == 1
figure; hold on; plot(xVals,yVals,'k-')
plot(X,P,'ro')
end

N(X<refVal) = C(X<refVal) - N(X<refVal);
startLoc = [10 2 0];
fixedYN = [1 0 1];
param = fit_cumulativeNormal(X,N,C,startLoc,fixedYN);

all_mu(kk) = param.mu;
all_sigma(kk) = param.sigma;

end

figure; hist(all_mu-mu); title('Difference between true \mu and fitted \mu');
figure; hist(all_sigma-sigma); title('Difference between true \sigma and fitted \sigma');

end

