function [frameType,earL,earR] = twoStreamAV_PoissonProcess(lambdaR,lambdaT,locR,dur,tStep,nTrials,nOff,truePoisson)

if nargin < 8
    truePoisson = 1;
    if nargin < 7
        nOff = 1;
        if nargin < 6
            nTrials = 1;
        end
    end
end

assert(length(locR)==nTrials,'Check that locR and nTrials are compatible.')

% Generate Poisson processes:
if truePoisson == 1
    eventsRef = makePoissonProcess(lambdaR,1,dur,tStep,nTrials);
    eventsTest = makePoissonProcess(lambdaT,1,dur,tStep,nTrials);
else
    eventsRef = makeFakePoissonProcess(lambdaR,dur,tStep,nTrials);
    eventsTest = makeFakePoissonProcess(lambdaT,dur,tStep,nTrials);
end

% Add in off frames and add stream asynchrony: 
ER = zeros(1,length(eventsRef)*(nOff+1));
ET = ER;
rr = 1:(nOff+1);
for ii = 1:2
   idx = randi(length(rr));
   if ii == 1 
      ER(rr(idx):(nOff+1):end) = eventsRef; 
   elseif ii == 2
       ET(rr(idx):(nOff+1):end) = eventsTest;
   end
   rr(idx) = [];
end

% Convert to frame type ID:
nSteps = round(dur/tStep);
eventsRef = ER'.*repmat(locR,nSteps*(nOff+1),1);
eventsTest = ET'.*repmat(-locR,nSteps*(nOff+1),1);
frameType = (eventsRef + eventsTest);
frameType((abs(eventsRef)+abs(eventsTest))==2) = 4; % Both left and right events
frameType(frameType==1) = 3; % Right event only
frameType(frameType==-1) = 2; % Left event only
frameType(frameType==0) = 1; % No events

% Auditory Channels:
earL = frameType;
earL(earL == 1) = 0;
earL(earL == 3) = 0;
earL(earL~= 0) = 1;
earR = frameType;
earR(earR == 1) = 0;
earR(earR == 2) = 0;
earR(earR ~= 0) = 1;

end