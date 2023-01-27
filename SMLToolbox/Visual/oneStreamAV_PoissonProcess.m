function [frameType,ear] = oneStreamAV_PoissonProcess(lambda,dur,tStep,nTrials,nOff,truePoisson)
% ONESTREAMAV_POISSONPROCESS This function generates a pseudorandom
% sequence of events (1=event, 0=otherwise). The generating rate of events
% (lambda) will be used to determine the probability of an event in each
% time bin (tStep). The actual rate of the sequence (lambda') will vary
% randomly around the generating rate. Dead time after each event is
% determined by the "nOff" parameter, which is the number of tSteps dead
% time between events. 

if nargin < 6
    truePoisson = 1;
    if nargin < 5
        nOff = 1;
        if nargin < 4
            nTrials = 1;
        end
    end
end

% Generate Poisson processes:
if truePoisson == 1
    events = makePoissonProcess(lambda,1,dur,tStep,nTrials);
else
    events = makeFakePoissonProcess(lambda,dur,tStep,nTrials);
end
lEvents = length(events);

% Add in off frames with variation in the placement of events:
E = zeros(nOff+1,lEvents);
nBack_events = [0; (events(1:end-1)+events(2:end))];
for ii = 1:lEvents
    if nBack_events(ii) ~= 2 % event in both current and previous bin
       loc = randi(nOff+1); 
    end
    E(loc,ii) = events(ii);
end

E = E(:);
E = E';

% Convert to frame type ID (1 = no event, 2 = event):
frameType = E + 1; 

% Auditory Channels:
ear = E;

end