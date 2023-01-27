function [] = AVTemporalTask_controlExp(subject,session,restartYN)
%AVTEMPORALTASK_CNTROLEXP: This experiment presents click-flash sequences
%to participants who will respond if the two streams came from a common
%source or not. All 4 spatiotemporal conlict configurations are tested in a
%mixed manner.

% Created by SML May 2016

% --------
% Defaults
% --------

if nargin < 3
    restartYN = 0;
    if nargin < 2
        session = 1; 
        if nargin < 1
            subject = 'TEST';
        end
    end
end

tBeginExp = GetSecs; 
trialUpdates = 1;
set(0,'DefaultFigureWindowStyle','docked')
makeTriviaQandA

% ---------------------
% Data Storage Preamble
% ---------------------

if ~strcmp(subject,'TEST')
    expName = 'AVTemporalTask_controlExp';
    [exp,fSaveFile,tSaveFile,restart] = expDataSetup(expName,subject,session,'randomSeq',restartYN);
else
    fSaveFile = 'TestRun';
    tSaveFile = 'TestRun';
end

%----------------
% Prepare Devices
%----------------

exp.hardware = prepDevices(1,1);
v2struct(exp.hardware)

% Keyboard inputs:
kLeft = KbName('leftarrow');
kRight = KbName('rightarrow');

% ---------------
% Generate Trials
% ---------------

if restartYN == false
    
    % Get design matrix and stimulus parameters:
    [designMat,expDesign,VIS,AUD,designMat_Legend,all_frameType,all_ear] = paramAVTemporalTask_controlExp(exp.hardware);
    v2struct(expDesign)
    
    % Store all experiment info in temp file:
    exp.designMat = designMat;
    exp.designMat_Legend = designMat_Legend;
    exp.expDesign = expDesign;
    exp.VIS = VIS;
    exp.AUD = AUD;
    save(tSaveFile, 'exp');
    
    nn = 1; % Start at trial 1
    
else % A restart
    
    load(restart.filename) % Load previous save file
    nn = restart.nextTrial; % Start at next trial
    v2struct(exp)
    v2struct(expDesign)
    
end

% -- AUDIO MIXER -- %

pamaster = PsychPortAudio('Open', [], devMode, rlc, AUD.freq, nChannels);
% pahandle = PsychPortAudio('Open' [, deviceid][, mode][, reqlatencyclass][, freq][, channels][, buffersize][, suggestedLatency][, selectchannels][, specialFlags=0]);

% Start master immediately and have it repeat indefinitely. Also, wait for the
% device to be started. We won't stop the master until the end of the session.
PsychPortAudio('Start', pamaster, 0, 0, 1);
% startTime = PsychPortAudio('Start', pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);

% Set the volume for all stimuli to be played:
PsychPortAudio('Volume', pamaster, 1);

% Make slave device:
paslave = PsychPortAudio('OpenSlave', pamaster, 1); % virtual device 1

% ---------------
% Open the screen
% ---------------

AssertOpenGL;
screens=Screen('Screens');
screenID=max(screens);
w = Screen('OpenWindow', screenID, 127);
Priority(MaxPriority(w));
Screen('Flip', w); % do initial flip

% ---------------
% Prepare Stimuli
% ---------------

% -- Auditory Stimuli -- %

v2struct(AUD)

% Broadband noise click stimulus:
click = makeWhiteNoise(1,3,lowF,highF,clickDur,freq,0); % Broadband white noise
click = applyCosRamp_ms(click,cosWin,freq); % ramped
% plot(t,click)

% Alert beep:
t = 0:1/freq:clickDur; % samples
alert = sin(2*pi*alertBeepFreq*t);
alert = applyCosRamp_ms(alert,cosWin,freq); % ramped
alert = alert(:);

% -- Visual Stimuli -- %

% Build textures:
v2struct(VIS)
fixFrame_white = makeFixationCrossTexture(crossLen,127,255);
fixFrame_black = makeFixationCrossTexture(crossLen,127,0);
frames = make1StreamPoissonFlashFrames(sizeTex_pix,SD_pix,fixFrame_white,fixCrossLoc);

% Load textures: 
off = Screen('MakeTexture', w, frames{1});
on = Screen('MakeTexture', w, frames{2});
fixFrame_black = Screen('MakeTexture', w, fixFrame_black);
fixFrame_white = Screen('MakeTexture', w, fixFrame_white);

% --------------------
% Prepare Instructions
% --------------------

instructionsText = 'Please read the experiment instructions sheet. Afterwards, press the down key to continue.';

% -------------------------------------------------------------------------
%                        !!!  RUN EXPERIMENT  !!!
% -------------------------------------------------------------------------

% ------------------------
% Participant Instructions
% ------------------------

quickPrintText(w,instructionsText)

% ----------------
% Begin Trial Loop
% ----------------

% Create matrices for storing results and what not:
nFrames = expDesign.trialDur * exp.hardware.fps; % number of frames
if restartYN == 0
    resMat = [designMat, NaN(expDesign.nTrials,1)];
    resMat_Legend = {designMat_Legend, 'Common Source YN'};
end

tKeyPress = GetSecs; % Start timer

while nn <= nTrials
    
    % ----------------
    % Generate Stimuli
    % ----------------
    
    % Convert frameType to texture ID:
    frameType = all_frameType(:,nn);
    frameType(frameType==0) = off;
    frameType(frameType==1) = on;
    
    % Create auditory buffers:
    seq = repmat(all_ear(:,nn)',length(click),1);
    iEar = find(seq==1);
    seq(iEar) = repmat(click,1,sum(all_ear(:,nn)));
    s = [zeros(size(alert)); alert; seq(:); alert]; % add in alert beeps
    s = rescaleSound(s,2,0); % Scale sound to ensure it is the full range
    s = [s zeros(length(s),1)]; % play through central speaker
    
    % ---------------
    % Present Stimuli
    % ---------------
    
    frame = 1; % Frame counter
    
    % Inter-stimulus interval taking into account processing time:
    tStart = GetSecs;
    tElap = tStart - tKeyPress;
    WaitSecs(ISI - clickDur - tElap);
    if (ISI-tElap) < 0
        disp('ISI is longer than the set value!')
    end
    
    % Cue start of trial by fixation cross appearance:
    Screen('DrawTexture', w, fixFrame_black);
    Screen('Flip', w);
    WaitSecs(fixCueTime);
    
    % Present Auditory Sequence:
    paslave_buff = PsychPortAudio('CreateBuffer', [], s');
    PsychPortAudio('UseSchedule', paslave, 1); % Prepare a schedule
    PsychPortAudio('AddToSchedule', paslave, paslave_buff); % Fill schedule
    audioStartTime = PsychPortAudio('Start', paslave, [], [], 1);
    WaitSecs(2 * clickDur); % wait for alert beep
    
    % Present Visual Sequence:
    while frame <= nFrames
        Screen('DrawTexture', w, frameType(frame),[],textureLoc);
        Screen('DrawTexture', w, fixFrame_white);
        VBLTimestamp = Screen('Flip', w);
        frame = frame + 1; % Update counter
    end
    
    % Clear Screen:
    Screen('FillRect', w, [127 127 127]);
    Screen('Flip', w);
    
    % Indicate end of sequence:
    quickPrintText(w,'---',[],[],[],[],0,clickDur);
    
    % Stop Audio playback:
    % WaitSecs(clickDur);
    [startTime,~,~,estStopTime] = PsychPortAudio('Stop', paslave);
    PsychPortAudio('DeleteBuffer', paslave_buff, 1);
    
    
    
    % ---------------------
    % Get and Rate Response
    % ---------------------
    
    % Record response:
    respKey = 0;
    while ~(respKey == kLeft || respKey == kRight)
        respKey = key_resp(-1);
    end
    tKeyPress = GetSecs;
    if respKey == kLeft
        respVal = 1; % [Left keypress = common source]
    else
        respVal = 0; % [Right keypress = two sources]
    end
    
    % ---------------
    % Saving Results:
    % ---------------
    
    % Update results matrix:
    resMat(nn,end) = respVal;
    
    % Occassional things:
    if nn/5 == round(nn/5) % Every 5 trials update temp file
        save(tSaveFile,'exp','all_frameType','all_ear','resMat','resMat_Legend','nn')
        if nn/25 == round(nn/25) % Every 25 trials take a break!
            progressText = sprintf('%d/%d trials completed. Enjoy some quick trivia (use down key).',nn,nTrials);
            quickPrintText(w,progressText);
            triviaBreak(w,5);
            quickPrintText(w,'Press the down key to continue with experiment.');
        end
    end
    
    nn = nn + 1; % Update trial counter
end

% -----------------
% Save And Shutdown
% -----------------

save(fSaveFile,'exp','all_frameType','all_ear','resMat','resMat_Legend')
PsychPortAudio('Close');
sca;

% Report total elapsed time:
tEndExp = GetSecs;
exp.timeToCompleteExp = tEndExp-tBeginExp;
disp('Total running time:')
disp(exp.timeToCompleteExp);

end