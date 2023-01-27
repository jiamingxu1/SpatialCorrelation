 function [] = AVTemporalTask_rateJND_V5(subject,session,restartYN,trainingYN)
%AVTEMPORALTASK_RATEJND_V5 is a rate discrimination task using the
%comparison-to-standard method. A single stream of Poisson unisensory or
%multisensory clicks/flashes will be presented, the subject has to judge if
%the rate is faster than the standard.
%
% THIS VERSION DIFFERS FROM THOSE PREVIOUS BY ALSO MANIPULATING SPATIAL
% CORRELATION.
%
% Created by SML July 2015

% --------
% Defaults
% --------

if nargin < 4
    trainingYN = 1;
    if nargin < 3
        restartYN = 0;
        if nargin < 2
            session = 1;
            if nargin < 1
                subject = 'TEST';
            end
        end
    end
end

tBeginExp = GetSecs; 
trialUpdates = 1;
% trainingYN = 0;
set(0,'DefaultFigureWindowStyle','docked')

% ---------------------
% Data Storage Preamble
% ---------------------

if ~strcmp(subject,'TEST')
    expName = 'AVTemporalTask_rateJND_V5';
    [exp,fSaveFile,tSaveFile,restart] = expDataSetup(expName,subject,session,[],restartYN);
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
    [designMat,expDesign,VIS,AUD,designMat_Legend] = paramAVTemporalTask_rateJND_V5(exp.hardware,session);
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

% fixFrame = frames{1};
% fixFrame(fixFrame==255) = 0; % Make fixation cross black prior to presentation

% Load textures: 
off = Screen('MakeTexture', w, frames{1});
on = Screen('MakeTexture', w, frames{2});
fixFrame_black = Screen('MakeTexture', w, fixFrame_black);
fixFrame_white = Screen('MakeTexture', w, fixFrame_white);

% -- Cells to Store Sequences -- %
all_frameType = cell(nTrials,1);
all_ear = cell(nTrials,1);
all_frameType_standard = cell(nTrials/5,1);
all_ear_standard = cell(nTrials/5,1);

% --------------------
% Prepare Instructions
% --------------------

instructionsText = 'Please read the experiment instructions sheet. Afterwards, press the space-bar to continue.';
feedbackText = {'wrong','correct'};
modalityCueText = {'V','A','AV'};
% locationCueText = {'     ','  -->';'<--  ','     '};

% -------------------
% Prepare UML objects
% -------------------

exp.expDesign.xScale = 1;
par = get_UMLpar(exp.expDesign.xScale);
if restartYN == 0
visUML = UML(par);
audUML = UML(par);
multUML = UML(par);
end

vv = figure;
aa = figure;
mm = figure;

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

tKeyPress = GetSecs; % Start timer
refRate = designMat(1,1);

if trainingYN == 1
    nTrials = 150;
end

while nn <= nTrials
    
    % ------------------------
    % Get Parameters for Trial
    % ------------------------
    
    % Select stimulus intensity:
    switch designMat(nn,2)
        case 1 % Visual
            currLambda = visUML.xnext / exp.expDesign.xScale;
        case 2 % Auditory
            currLambda = audUML.xnext / exp.expDesign.xScale;
        case 3 % Multisensory
            currLambda = multUML.xnext / exp.expDesign.xScale;
    end
    
    % Add the test stimulus intensity to cue:
    cuedLambda = currLambda;
    
    % --------------
    % Show Standard?
    % --------------
    
    if mod(nn-1,5) == 0 % First trial, then every 5 trials
        cuedLambda = [refRate cuedLambda];
        durVal = trialDur;
        modOpt = 3;
        quickPrintText(w,'Standard Stimulus',[],[],[],[],1,0.3);
    end
    
    % ----------------------------
    % Generate and Present Stimuli
    % ----------------------------
    
    while ~isempty(cuedLambda)
        
        % Get stimulus parameters:
        if length(cuedLambda) == 1 % Comparison stimulus to be shown
            durVal = designMat(nn,3);
            modOpt = designMat(nn,2);
            seqOpt = 0;
        else % Standard stimulus to be shown
            seqOpt = 0;
        end
        
        % Generate sequence:
        if tempSyncYN == 1
            [frameType,ear] = oneStreamAV_PoissonProcess(cuedLambda(1),durVal,tStep,1,nOff,seqOpt);
        else
            [frameType,~] = oneStreamAV_PoissonProcess(cuedLambda(1),durVal,tStep,1,nOff,seqOpt);
            [~,ear] = oneStreamAV_PoissonProcess(cuedLambda(1),durVal,tStep,1,nOff,seqOpt);
        end
        
        % Save sequence:
        if length(cuedLambda) == 1 % Comparison stimulus to be shown
            all_frameType{nn} = frameType;
            all_ear{nn} = ear;
        else % Standard stimulus to be shown
            idx = (nn-1)/5 + 1;
            all_frameType_standard{idx} = frameType;
            all_ear_standard{idx} = ear;
        end
        
        % Determine acutal rate of stimulus:
        actualRate_v = length(frameType(frameType==2))/durVal;
        actualRate_a = length(ear(ear==1))/durVal;
        if modOpt == 1
            actualRate = actualRate_v;
        elseif modOpt == 2
            actualRate = actualRate_a;
        elseif modOpt == 3
            actualRate = mean([actualRate_v actualRate_a]);
        end
        
        % Convert frameType to texture ID:
        if modOpt == 2 % Auditory only
            frameType = off * ones(size(frameType));
        else
            frameType(frameType==1) = off;
            frameType(frameType==2) = on;
        end
        
        % Create auditory buffers:
        seq = repmat(ear,length(click),1);
        iEar = find(seq==1);
        seq(iEar) = repmat(click,1,sum(ear));
        if modOpt == 1 % Visual only
            seq(:) = zeros(size(seq(:)));
        end
        s = [zeros(imposedDelay_samples,1); alert; seq(:); alert]; % add in alert beeps
        s = rescaleSound(s,2,0); % Scale sound to ensure it is the full range
        s = volScaleFactor(spatialSyncYN+1) * s; % Scale so speaker intensities are matched
        
        % Choose which channel to play from:
        if spatialSyncYN == 0 % Play through lateral speaker, channel __
            s = [zeros(length(s),1) s];
        elseif spatialSyncYN == 1 % Play through central speaker, channel __
            s = [s zeros(length(s),1)];
        end
        
        % Controls for presentation time:
        frame = 1; % Frame counter
        nFrames = length(frameType); % number of frames
        
        % Inter-stimulus interval taking into account processing time:
        if length(cuedLambda) == 1
            tStart = GetSecs;
            tElap = tStart - tKeyPress;
            WaitSecs(ISI-tElap);
            if (ISI-tElap) < 0
                disp('ISI is longer than the set value!')
            end
        end
        
        % Modality and spatial cue:
        if length(cuedLambda) == 1 % Comparison stimulus to be shown
            combCueTxt = modalityCueText{modOpt};
%             if (spatialSyncYN == 0) && (modOpt ~= 1);
%                 combCueTxt = [locationCueText{spatLoc(nn),1} combCueTxt locationCueText{spatLoc(nn),2}];
%             end
            quickPrintText(w,combCueTxt,[],[],[],[],[],0.5);
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
%         status1_ear = PsychPortAudio('GetStatus', paslave);
        WaitSecs(clickDur);
        
        % Present Visual Sequence:
        while frame <= nFrames
            Screen('DrawTexture', w, frameType(frame),[],textureLoc);
            Screen('DrawTexture', w, fixFrame_white);
%             status2_ear = PsychPortAudio('GetStatus', paslave);
            VBLTimestamp = Screen('Flip', w);
             frame = frame + 1; % Update counter
            if frame == 2
                x = 6;
            end
        end
        
        % Clear Screen:
        Screen('FillRect', w, [127 127 127]);
        Screen('Flip', w);
        
        % Stop Audio playback:
        WaitSecs(clickDur);
        [startTime,~,~,estStopTime] = PsychPortAudio('Stop', paslave);
        PsychPortAudio('DeleteBuffer', paslave_buff, 1);
        
        cuedLambda(1) = [];
        if ~isempty(cuedLambda)
            quickPrintText(w,'---',[],[],[],[],[],0.3);
            tKeyPress = GetSecs;
        end
    end
    
    % ---------------------
    % Get and Rate Response
    % ---------------------
    
    % Record response:
    respKey = 0;
    while ~(respKey == kLeft || respKey == kRight)
        respKey = key_resp(-1);
    end
    tKeyPress = GetSecs;
    
    % Determine if correct or incorrect (based on actual rate):
    if ((respKey == kLeft) && (refRate>actualRate)) || ((respKey == kRight) && (refRate<actualRate))
        respVal = 1;
    else
        respVal = 0;
    end
    % [Left keypress = slower than standard, Right keypress = faster than standard]
    
    % -----------------
    % Update UML object
    % -----------------
    
    % Judged faster than standard?
    r = 0;
    if respKey == kRight
        r = 1;
    end
    
    % Adjust UML objects:
    switch designMat(nn,2)
        case 1 % Visual
            visUML.xnext = actualRate * exp.expDesign.xScale;
            visUML.update(r);
            disp(visUML.phi(end,:))
            figure(vv)
            visUML.plotP()
        case 2 % Auditory
            audUML.xnext = actualRate * exp.expDesign.xScale;
            audUML.update(r);
            disp(audUML.phi(end,:))
            figure(aa)
            audUML.plotP()
        case 3 % Multisensory
            multUML.xnext = actualRate * exp.expDesign.xScale;
            multUML.update(r);
            disp(multUML.phi(end,:))
            figure(mm)
            multUML.plotP()
    end
    
    % ----
    % Misc
    % ----
    
    % Display data in command window if trial updates requested:
    if trialUpdates == 1
        tu1 = sprintf('\n\n Reference rate:  %.1f',refRate);
        tu2 = sprintf('Test rate:  %.4f',currLambda);
        tu3 = sprintf('Response:  %d',respVal);
        tu4 = sprintf('Actual test rate:  %.1f',actualRate);
        disp(tu1)
        disp(tu2)
        disp(tu3)
        disp(tu4)
    end
    
    % Give feedback:
    quickPrintText(w,feedbackText{respVal+1},[],[],[],[],[],0.3);
    
    % Update temp file:
    if nn/5 == round(nn/5) % Every 5 trials
        save(tSaveFile,'exp','all_frameType','all_ear','visUML','audUML','multUML','nn')
        if nn/50 == round(nn/50) % Every 50 trials
            progressText = sprintf('%d/%d trials completed. Press the space-bar to continue.',nn,nTrials);
            quickPrintText(w,progressText);
        end
    end
    
    nn = nn + 1; % Update trial counter
end

% -----------------
% Save And Shutdown
% -----------------

save(fSaveFile,'exp','all_frameType','all_ear','all_frameType_standard','all_ear_standard','visUML','audUML','multUML')
PsychPortAudio('Close');
sca;

% Report total elapsed time:
tEndExp = GetSecs;
exp.timeToCompleteExp = tEndExp-tBeginExp;
disp('Total running time:')
disp(exp.timeToCompleteExp);

end