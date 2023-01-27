function [nextVal,switchCorr,stop] = staircase_1up2down_crisscross(refVal,stimVals,respVals,stepSize,stopCrit)
% STAIRCASE_1UP2DOWN is a transformed up/down method that targets 70.71%
% correct (Wetherill & Levitt, 1965). Stimulus intensity will increase
% after every incorrect response, and decrease only after two consecutive
% correct responses.
%
% [NEXTVAL,STOP] = staircase_1up2down(REFVAL,STIMVALS,RESPVALS,STEPSIZE,STOPCRIT)
%
% REFVAL: Is the reference stimulus value.
% STIMVALS: This is a vector of all presented test stimulus values.
% RESPVALS: This is a vector of 1 and 0's indicating if the subject gave
%           the correct answer.
% STEPSIZE: Single step size for increments and decrements.
% STOPCRIT: Stopping criterion. 0 for no stopping criterion.
%
% NEXTVAL: Next stimulus value.
% SWITCHCORR: The next stimulus value is on the opposite side of the
%             reference value compared to the starting value.
% STOP: Flag to terminate staircase if stopping criterion is met.
%
% Created by SML April 2015

if nargin < 5
    stopCrit = 0; % no stopping criterion
end

% Some nagging:
assert(length(refVal)==1,'Enter only a single reference value!')
assert(length(stepSize)==1,'Enter only a single step size value!')
assert(min(size(stimVals))==1,'Enter a vector of stimulus values!')
assert(min(size(respVals))==1,'Enter a vector of stimulus values!')
assert(length(stimVals)==length(respVals),'Must have same number of entries for stimulus and response vectors!')

% Convert stimulus value to difference:
diffVals = stimVals - refVal; % difference between reference and test stim
diffSign = sign(diffVals(end)); % wrt to last stimulus
diffVals = abs(diffVals); % need to work with abs val to know up from down

% Calculate the number of reversals:
if length(stimVals) == 1
    reversals = 0;
else
    cumResp = respVals(2:end) + respVals(1:end-1);
    reversals = length(cumResp(cumResp==1));
end

% Determine the next stimulus value:
if respVals(end) == 0 % INCORRECT RESPONSE --> increase stimulus value
    
    nextVal = diffVals(end) + stepSize;
    
else % CORRECT RESPONSE
    
    if reversals == 0 || diffVals(end) == 0
        % (Only 1 trial completed or no reversals or at ref val)
        nextVal = diffVals(end) - stepSize; % --> decrease stimulus value
    elseif (diffVals(end) ~= diffVals(end-1)) % not 2 consecutive correct responses
        nextVal = diffVals(end); % --> same stimulus value
    else % 2 consecutive correct responses
        nextVal = diffVals(end) - stepSize; % --> decrease stimulus value
    end
    
end

% Do not present refVal in both streams:
if nextVal == 0
    nextVal = sign(rand-0.5) * stepSize;
end

% Convert nextVal to stimulus intensity:
nextVal = refVal + diffSign * nextVal;
nextVal = roundn(nextVal,3); % weird rounding...?

% Determine if staircase has dipped above/below refVal from starting point:
switchCorr = 1;
if sign(nextVal-refVal) ~= sign(stimVals(1)-refVal)
    switchCorr = -1;
end

end