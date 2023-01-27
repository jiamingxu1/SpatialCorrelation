%% Present sound stimuli (testing) 

% This script presents (single) auditory stimuli in all possible locations for the
% purpose of recording spatial sound (testing)
clear all; close all; clc; rng('shuffle');

%% Setup variables

display = 2; % 1:testing room; 2:my laptop

ExpInfo.subjID = [];
while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
    end
end

ExpInfo = setup_param(display); 
[yMat, freqMat, nrchannels] = load_aud(ExpInfo); % Load the sound files 
ScreenInfo = setup_screen(display);
kb.escKey = KbName('ESCAPE');


%% Open the motorArduino
motorArduino            = serial('/dev/cu.usbmodemFA1341'); 
motorArduino.Baudrate   = 9600;
motorArduino.StopBits   = 1;
motorArduino.Terminator = 'LF';
motorArduino.Parity     = 'none';
motorArduino.FlowControl= 'none';
fopen(motorArduino);
pause(2);
noOfSteps = 3200;  

%% open loudspeakers and create sound stimuli 
PsychDefaultSetup(2);
% get correct sound card
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device = [devices(1).DeviceIndex devices(2).DeviceIndex]; % one for earphones one for speaker

%% create auditory stimuli
%white noise for mask noise
AudInfo.fs              = 44100;
audioSamples            = linspace(1,AudInfo.fs,AudInfo.fs);

%for gaussion white noise
standardFrequency_gwn       = 10;
AudInfo.adaptationDuration  = 0.1; %0.05 %the burst of sound will be displayed for 40 milliseconds
duration_gwn                = length(audioSamples)*AudInfo.adaptationDuration;
timeline_gwn                = linspace(1,duration_gwn,duration_gwn);
sineWindow_gwn              = sin(standardFrequency_gwn/2*2*pi*timeline_gwn/AudInfo.fs); 
carrierSound_gwn            = randn(1, max(timeline_gwn)); %？？it's our gaussian auditory stimulus
AudInfo.intensity_GWN       = 15;
AudInfo.GaussianWhiteNoise  = [zeros(size(carrierSound_gwn));... % gaussian noise*intensity*sin window
                                 AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn]; 
pahandle                    = PsychPortAudio('Open', our_device, [], [], [], 2);%open device

% PsychPortAudio - A sound driver built around the PortAudio sound library

%% Specify the locations of the auditory stimulus 
% store the differences between standard and test four locations
AudInfo.waitTime        = 2; 
AudInfo.InitialLoc      = -7.5;
AudInfo.locs            = Shuffle(linspace(-18,18,6));
AudInfo.numLocs         = length(AudInfo.locs); 
AudInfo.numTrialsPerLoc = 2; %2 for practice, 20 for the real experiment
AudInfo.numTotalTrials  = AudInfo.numTrialsPerLoc * AudInfo.numLocs;

%create a matrix whose 1st column is initial position and 2nd column is final position
AudInfo.Location_Matrix = [[AudInfo.InitialLoc, AudInfo.locs(1:end-1)]',...
                                 AudInfo.locs'];
sittingDistance  = 105; %FH: need to define this before using it in line 100
initialPosition  = AudInfo.Location_Matrix(:,1);
finalPosition    = AudInfo.Location_Matrix(:,2);   
getDist          = @(deg) tan(deg2rad(deg))*sittingDistance; %distance in (cm) between the speaker location and the central fixation
movingSteps      = zeros(length(initialPosition),1);

for i = 1:length(initialPosition)
    movingSteps(i) = (getDist(finalPosition(i))-getDist(initialPosition(i)))/3; %in steps
end


%% Present auditory stimuli 
    
for i = 1:length(initialPosition)
    
    %display Mask Noise
    PsychPortAudio('FillBuffer', pahandle, AudInfo.MaskNoise);
    PsychPortAudio('Start', pahandle, 0, 0, 1);
    
    % Move the speaker to the location we want
    movingSteps_i = movingSteps(i); 
    waitTime1     = FindWaitTime(movingSteps_i);

    if movingSteps_i < 0  %when AuditoryLoc is negative, move to the left
        fprintf(motorArduino,['%c','%d'], ['p', noOfSteps*abs(movingSteps_i)]);
    else
        fprintf(motorArduino,['%c','%d'], ['n', noOfSteps*movingSteps_i]);
    end
    %wait shortly
    WaitSecs(waitTime1);
    %wait shortly
    WaitSecs(AudInfo.waitTime);
    PsychPortAudio('Stop', pahandle);

    % Display auditory stimuli
    % Show fixation cross for 1 s and then a blank screen for 2 s
    Screen('FillRect', windowPtr,[255 255 255], [ScreenInfo.x1_lb,ScreenInfo.y1_lb,...
        ScreenInfo.x1_ub, ScreenInfo.y1_ub]);
    Screen('FillRect', windowPtr,[255 255 255], [ScreenInfo.x2_lb,ScreenInfo.y2_lb,...
        ScreenInfo.x2_ub, ScreenInfo.y2_ub]);
    Screen('Flip',windowPtr); WaitSecs(0.5);
    Screen('Flip',windowPtr); WaitSecs(0.5); 

    for j = 1:AudInfo.numTrialsPerLoc
        PsychPortAudio('FillBuffer', pahandle, AudInfo.GaussianWhiteNoise);
        PsychPortAudio('Start', pahandle, 1, 0, 0);
        WaitSecs(AudInfo.adaptationDuration);
        PsychPortAudio('Stop', pahandle);

        % Black screen for 0.5 seconds
        Screen('Flip',windowPtr);
        WaitSecs(2);
    end
end


%% Move the arduino to the leftmost place
if abs(AudInfo.InitialLoc - AudInfo.Location_Matrix(end))>=0.01
    steps_goingBack = round((tan(deg2rad(AudInfo.InitialLoc))-...
                      tan(deg2rad(AudInfo.Location_Matrix(end))))*...
                      sittingDistance/3,2);
    if steps_goingBack < 0 
        fprintf(motorArduino,['%c','%d'], ['p',noOfSteps*abs(steps_goingBack)]);
    else
        fprintf(motorArduino,['%c','%d'], ['n',noOfSteps*abs(steps_goingBack)]);
    end 
end
delete(motorArduino)
% Screen('CloseAll');

%% Play recordings

% PsychDefaultSetup(2);
% InitializePsychSound
% devices = PsychPortAudio('GetDevices');
% device = devices(2).DeviceIndex; % my laptop

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

