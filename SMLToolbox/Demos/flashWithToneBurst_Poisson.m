% Make a Poisson process for each auditory channel:
lambdaL = 5; % event rate in events/sec
lambdaR = 8;
dur = 5; % total stimulus duration
tStep = 1/30; % time steps (2 * refresh rate of monitor)
[frameType,eL,eR] = twoStreamAV_PoissonProcess(lambdaR,lambdaL,1,dur,tStep,1,1);

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
seqL = repmat(eL',length(s),1);
seqR = repmat(eR',length(s),1);
iL = find(seqL==1);
iR = find(seqR==1);
seqL(iL) = repmat(s,sum(eL),1);
seqR(iR) = repmat(s,sum(eR),1);
s = [seqL(:) seqR(:)];

%Create visual frames:
sizeTex = 300;
centDist = 1920/4;
SD = 50;
frames = make2StreamPoissonFlashFrames(sizeTex,SD,centDist);

% Open Screen:
AssertOpenGL;
screens=Screen('Screens');
screenID=max(screens);
[w, rect] = Screen('OpenWindow', screenID, 0);
Priority(MaxPriority(w));
Screen('Flip', w);

% Make Textures:
aa = Screen('MakeTexture', w, frames{1});
bb = Screen('MakeTexture', w, frames{2});
cc = Screen('MakeTexture', w, frames{3});
dd = Screen('MakeTexture', w, frames{4});
frameType(frameType==1) = aa;
frameType(frameType==2) = bb;
frameType(frameType==3) = cc;
frameType(frameType==4) = dd;

% Play sound:
player = audioplayer(s,freq);
play(player);
WaitSecs(0.1);

% Play flash sequence:
idx = 1;
maxN = length(frameType);
while idx <= maxN
    Screen('DrawTexture', w, frameType(idx));
    Screen('Flip', w);
    idx = idx + 1;
end

disp(sum(eL))
disp(sum(eR))

% Shut down:
WaitSecs(0.5);
stop(player);
sca;