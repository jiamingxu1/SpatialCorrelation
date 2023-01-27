function events = makeFakePoissonProcess(lambda,dur,tStep,N)
% MAKEFAKEPOISSONPROCESS creates a vector with an exact number of events
% based on the intended rate lambda and stimulus duration.
%
% [Y] = makeFakePoissonProces(LAMBDA,DUR,TSTEP,N)
%
% LAMBDA: intended event rate.
% DUR: duration of stimulus.
% TSTEP: the time increments in which an event may occur.
% N: number of sequences to be generated.
%
% Events: matrix containing for each time step in each sequence(a column),
% a flag of event (=1) or no event (=0).
%
% Created by SML April 2015

% Defaults:
if nargin < 4
    N = 1;
end

% assert((dur/tStep)==round(dur/tStep),'Make sure stimulus duration is an integer number of tSteps.')

nEvents = round(dur*lambda); % Number of events
if length(nEvents) == 1
    nEvents = repmat(nEvents,1,N);
end

nSteps = round(dur/tStep); % Number of time steps

assert(nSteps>max(nEvents),'You have selected at least one rate that is too high for the selected time step.')

events = zeros(nSteps,N); % Empty matrix

for ii = 1:N
    bins = randperm(nSteps); % Randomise the placement of events
    bins = bins(1:nEvents(ii));
    events(bins,repmat(ii,nEvents(ii),1)) = 1;
end

end