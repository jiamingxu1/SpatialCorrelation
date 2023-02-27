% Test speaker setup, display trains of auditory stimuli

%% Enter subject's name
clear all; close all; clc; rng('shuffle');
addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));

ExpInfo.subjID = [];
while isempty(ExpInfo.subjID) == 1
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; %'s'
    catch
    end
end

%% Screen Setup 
Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'SkipSyncTests', 1);
[windowPtr,rect] = Screen('OpenWindow', 0, [1,1,1]);
%[windowPtr,rect] = Screen('OpenWindow', 0, [0,0,0],[100 100 1000 480]); % for testing
[ScreenInfo.xaxis, ScreenInfo.yaxis] = Screen('WindowSize',windowPtr);
Screen('TextSize', windowPtr, 35) ;   
Screen('TextFont',windowPtr,'Times');
Screen('TextStyle',windowPtr,1); 

[center(1), center(2)]     = RectCenter(rect);
ScreenInfo.xmid            = center(1); % horizontal center
ScreenInfo.ymid            = center(2); % vertical center
ScreenInfo.backgroundColor = 105;
ScreenInfo.numPixels_perCM = 7.5;
ScreenInfo.liftingYaxis    = 300; 

%fixation locations
ScreenInfo.x1_lb = ScreenInfo.xmid-7; ScreenInfo.x2_lb = ScreenInfo.xmid-1;
ScreenInfo.x1_ub = ScreenInfo.xmid+7; ScreenInfo.x2_ub = ScreenInfo.xmid+1;
ScreenInfo.y1_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-1;
ScreenInfo.y1_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+1;
ScreenInfo.y2_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-7;
ScreenInfo.y2_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+7;

%% make auditory stimuli (gaussian white noise)
AudInfo.fs                  = 44100;
audioSamples                = linspace(1,AudInfo.fs,AudInfo.fs);
standardFrequency_gwn       = 10;
AudInfo.adaptationDuration  = 0.1; %0.05 %the burst of sound will be displayed for 40 milliseconds
duration_gwn                = length(audioSamples)*AudInfo.adaptationDuration;
timeline_gwn                = linspace(1,duration_gwn,duration_gwn);
sineWindow_gwn              = sin(standardFrequency_gwn/2*2*pi*timeline_gwn/AudInfo.fs); 
carrierSound_gwn            = randn(1, max(timeline_gwn));
AudInfo.intensity_GWN       = 15;
AudInfo.GaussianWhiteNoise  = [zeros(size(carrierSound_gwn));...
                                 AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn]; 

%% Create auditory/visual train

AudInfo.locs            = 1:1:16;
AudInfo.numTotalLocs    = length(AudInfo.locs);
AudInfo.nEvents         = 5;
AudInfo.iniTrainLoc     = 1:1:11;
AudInfo.nTrials       = 10; % for testing

% shuffle locations 
audTrain = NaN(AudInfo.nTrials, AudInfo.nEvents);
allSeqs = perms(1:AudInfo.nEvents);
for i = 1:AudInfo.nTrials
    audTrain(i,:) = allSeqs(i,:)+...
        AudInfo.iniTrainLoc(randi(numel(AudInfo.iniTrainLoc)));
end
                             
%% Open speakers and create sound stimuli 

addpath(genpath('/e/3.3/p3/hong/Desktop/Project5/Psychtoolbox'));
PsychDefaultSetup(2);
% get correct sound card
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(2).DeviceIndex;
%pahandle = PsychPortAudio('Open', our_device, [], [], [], 2);%open device
     
%% initialise serial object
% allSerialDev = serialportlist("all");
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',115200); 
% open for usage
fopen(Arduino);

%%
 fprintf(Arduino, ['%d','%d','%d','%d','%d'], [10,10,500,10,50]);


%%
delete(Arduino)


% %% Play bimodal aud vis trains
% 
% kb.keyIsDown = 0; % set escape key
% kb.keyCode = zeros(1,256);
% 
% iT = 1; 
% while ~kb.keyCode(kb.escKey) || iT <= ExpInfo.nTrial
%     
%     [kb.keyIsDown, kb.secs, kb.keyCode, kb.deltaSecs] = KbCheck(-1);
% 
%     currentAud = ExpInfo.design(iT);
%     ExpInfo.result(iT,1) = ExpInfo.actualAud(currentAud);
%     freq = freqMat(:,1);
%     wavedata = yMat{ExpInfo.fileOrder(currentAud),1};
%     
%     % show fixation
%     Screen('FillRect', ScreenInfo.windowPtr,[255 255 255], [ScreenInfo.x1_lb,ScreenInfo.y1_lb,...
%         ScreenInfo.x1_ub, ScreenInfo.y1_ub]);
%     Screen('FillRect', ScreenInfo.windowPtr,[255 255 255], [ScreenInfo.x2_lb,ScreenInfo.y2_lb,...
%         ScreenInfo.x2_ub, ScreenInfo.y2_ub]);
%     Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
%     Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
%     
    % start playing
%     pahandle = PsychPortAudio('Open', our_device, [], 0, freq, nrchannels);
%     PsychPortAudio('FillBuffer', pahandle, GWN);
%     PsychPortAudio('Start', pahandle, ExpInfo.repetitions, 0, 1);   
    
    PsychPortAudio('FillBuffer', pahandle, GWN);
    PsychPortAudio('Start', pahandle, 1, 0, 0);
    WaitSecs(AudInfo.adaptationDuration);
    PsychPortAudio('Stop', pahandle);
%     %black screen for 0.5 seconds
%     Screen('Flip',windowPtr);
%     WaitSecs(0.5);
%     
%     
% % get mouse location
% 
% yLoc = ScreenInfo.yaxis-ScreenInfo.liftingYaxis;
% SetMouse(randi(ScreenInfo.xmid*2,1), yLoc, ScreenInfo.windowPtr); buttons = 0;
% 
% while sum(buttons)==0
%     [x,~,buttons] = GetMouse; HideCursor;
%     Screen('FillRect', ScreenInfo.windowPtr, [0 300 0],[x-3 yLoc-24 x+3 yLoc-12]);
%     Screen('FillPoly', ScreenInfo.windowPtr, [0 300 0],[x-3 yLoc-12; x yLoc; x+3 yLoc-12]);
%     Screen('Flip',ScreenInfo.windowPtr,0,0);
%     
%     [kb.keyIsDown, kb.secs, kb.keyCode, kb.deltaSecs] = KbCheck(-1);
%     
%     if kb.keyCode(kb.escKey)
%         Screen('CloseAll');
%     end
%     
% end
% 
% % collect responses
% Response_pixel = x;
% Response_cm    = (Response_pixel -  ScreenInfo.xmid)/ScreenInfo.numPixels_perCM;
% ExpInfo.result(iT,2)   = rad2deg(atan(Response_cm/ExpInfo.sittingDistance));  
%     
% iT = iT+1;
% 
%     if iT > ExpInfo.nTrial
%          break
%     end
%     
% end
% Screen('Flip',ScreenInfo.windowPtr); WaitSecs(0.5);
% Screen('CloseAll');
% 
% %% Save data and end the experiment
% UniAlocalization_data = {ExpInfo,ScreenInfo}; % result in ExpInfo
% save(out1FileName,'UniAlocalization_data');
% Screen('CloseAll');
