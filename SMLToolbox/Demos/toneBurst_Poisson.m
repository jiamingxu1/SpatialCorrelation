% Make a Poisson process for each auditory channel:
lambdaL = 4; % event rate in events/sec
lambdaR = 2;
dur = 3; % total stimulus duration
tStep = 1/30; % time steps (refresh rate of monitor)
nSteps = dur/tStep;
eL = makePoissonProcess(lambdaL,1,dur,tStep,1);
eR = makePoissonProcess(lambdaR,1,dur,tStep,1);

% Insert no stimulus frames/samples:
eventsL = zeros(nSteps*2,1);
eventsR = eventsL;
eventsL(1:2:end-1) = eL;
eventsR(1:2:end-1) = eR;

% Auditory stimulus parameters:
freq = 48000; % sampling frequency
clickDur = 1/60; % Duration of trial in sec
tone = 700; % tone frequency in Hz
durRamp = 10; % cosine window in ms

% Generate ramped toned:
t = 0:1/freq:clickDur;
s = sin(2*pi*tone*t)';
s = applyCosRamp_ms(s,durRamp,freq);
% plot(t,s)

% Create auditory buffers:
seqL = repmat(eventsL',length(s),1);
seqR = repmat(eventsR',length(s),1);
iL = find(seqL==1);
iR = find(seqR==1);
seqL(iL) = repmat(s,sum(eventsL),1);
seqR(iR) = repmat(s,sum(eventsR),1);

% Play sound:
s = [seqL(:) seqR(:)];
player = audioplayer(s,freq);
play(player);