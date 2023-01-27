% Test speaker setup, display trains of auditory stimuli

%% Setup variables

display = 2; % 1:testing room; 2:my laptop

ExpInfo.subjID = [];
while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
    end
end

ExpInfo = setup_param(display); 
ScreenInfo = setup_screen(display);
kb.escKey = KbName('ESCAPE');

%% Open the Arduino
Arduino            = serial('/dev/cu.usbmodemFA1341'); 
Arduino.Baudrate   = 9600;
Arduino.StopBits   = 1;
Arduino.Terminator = 'LF';
Arduino.Parity     = 'none';
Arduino.FlowControl= 'none';
fopen(Arduino);
pause(2);
noOfSteps = 3200;  

%% Open speakers and create sound stimuli 

addpath(genpath(PsychtoolboxRoot))
PsychDefaultSetup(2);
% get correct sound card
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(3).DeviceIndex; % ????

%% Create auditory stimuli

GWN = makeWhiteNoise(display);
pahandle                    = PsychPortAudio('Open', our_device, [], [], [], 2);%open device

%% Create auditory/visual train

AudInfo.locs            = 1:1:16;
AudInfo.numTotalLocs    = length(AudInfo.locs);
AudInfo.nEvents         = 5;
AudInfo.iniTrainLoc     = 1:1:11;
AudInfo.nTrials       = 10; % for testing

% shuffle auditory locations
audTrain = NaN(AudInfo.nTrials, AudInfo.nEvents);
allSeqs = perms(1:nEvents);
for i = 1:AudInfo.nTrials
    audTrain(i,:) = allSeqs(i,:)+...
        AudInfo.iniTrainLoc(randi(numel(AudInfo.iniTrainLoc)));
end

%% Play bimodal aud vis trains

kb.keyIsDown = 0; % set escape key
kb.keyCode = zeros(1,256);

iT = 1; 
while ~kb.keyCode(kb.escKey) || iT <= ExpInfo.nTrial
    
    [kb.keyIsDown, kb.secs, kb.keyCode, kb.deltaSecs] = KbCheck(-1);

    currentAud = ExpInfo.design(iT);
    ExpInfo.result(iT,1) = ExpInfo.actualAud(currentAud);
    freq = freqMat(:,1);
    wavedata = yMat{ExpInfo.fileOrder(currentAud),1};
    
    % show fixation
    Screen('FillRect', ScreenInfo.windowPtr,[255 255 255], [ScreenInfo.x1_lb,ScreenInfo.y1_lb,...
        ScreenInfo.x1_ub, ScreenInfo.y1_ub]);
    Screen('FillRect', ScreenInfo.windowPtr,[255 255 255], [ScreenInfo.x2_lb,ScreenInfo.y2_lb,...
        ScreenInfo.x2_ub, ScreenInfo.y2_ub]);
    Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
    Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
    
    % start playing
    pahandle = PsychPortAudio('Open', device, [], 0, freq, nrchannels);
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    PsychPortAudio('Start', pahandle, ExpInfo.repetitions, 0, 1);   
    
    %black screen for 0.5 seconds
    Screen('Flip',windowPtr);
    WaitSecs(0.5);
    
    
% get mouse location

yLoc = ScreenInfo.yaxis-ScreenInfo.liftingYaxis;
SetMouse(randi(ScreenInfo.xmid*2,1), yLoc, ScreenInfo.windowPtr); buttons = 0;

while sum(buttons)==0
    [x,~,buttons] = GetMouse; HideCursor;
    Screen('FillRect', ScreenInfo.windowPtr, [0 300 0],[x-3 yLoc-24 x+3 yLoc-12]);
    Screen('FillPoly', ScreenInfo.windowPtr, [0 300 0],[x-3 yLoc-12; x yLoc; x+3 yLoc-12]);
    Screen('Flip',ScreenInfo.windowPtr,0,0);
    
    [kb.keyIsDown, kb.secs, kb.keyCode, kb.deltaSecs] = KbCheck(-1);
    
    if kb.keyCode(kb.escKey)
        Screen('CloseAll');
    end
    
end

% collect responses
Response_pixel = x;
Response_cm    = (Response_pixel -  ScreenInfo.xmid)/ScreenInfo.numPixels_perCM;
ExpInfo.result(iT,2)   = rad2deg(atan(Response_cm/ExpInfo.sittingDistance));  
    
iT = iT+1;

    if iT > ExpInfo.nTrial
         break
    end
    
end
Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
Screen('CloseAll');

%% Save data and end the experiment
UniAlocalization_data = {ExpInfo,ScreenInfo}; % result in ExpInfo
save(out1FileName,'UniAlocalization_data');
Screen('CloseAll');
