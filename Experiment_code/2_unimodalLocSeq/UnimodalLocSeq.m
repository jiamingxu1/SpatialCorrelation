%This script tests subjects' accuracy and precision in localizing the centroids
% of visual and auditory trains stimuli. The visual stimulus is a train of
% 5 gaussian blobs appearing in 5 different locations. The auditory
% stimulus is a train of 5 beeps appearing in 5 different locations. The
% task is to localize the centroid of each train (V/A interleaved). 

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

%% initialise serial object
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',9600); 
% open for usage
fopen(Arduino);

%% Open speakers and create sound stimuli 
PsychDefaultSetup(2);
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device=devices(3).DeviceIndex;

%% make auditory stimuli (beep)
AudInfo.fs                           = 44100;
AudInfo.stimDura                     = 0.1; % ExpInfo.stimFrame * ScreenInfo.ifi; %s, the duration of auditory stimulus
AudInfo.tf                           = 500;
AudInfo.beepLengthSecs               = AudInfo.stimDura;
beep                                 = MakeBeep(AudInfo.tf, AudInfo.beepLengthSecs, AudInfo.fs);
AudInfo.Beep                         = [beep; beep];
pahandle = PsychPortAudio('Open', our_device, [], [], [], 2); %open device

%% Specify the locations of the auditory stimulus ****
% store the differences between standard and test four locations
AudInfo.Distance        = round(ExpInfo.matchedAloc,2); %in deg
AudInfo.InitialLoc      = -7.5;
AudInfo.numLocs         = length(AudInfo.Distance); 
AudInfo.numTrialsPerLoc = 60; %2 for practice, 60 for the real experiment
AudInfo.numTotalTrials  = AudInfo.numTrialsPerLoc * AudInfo.numLocs;
%the order of presenting V/A (if 1: A; %if 2: V)
%Even when the trial is V, we still move the speaker
ExpInfo.order_VSnAS     = [];
for i = 1:AudInfo.numTotalTrials
    ExpInfo.order_VSnAS = [ExpInfo.order_VSnAS, randperm(2,2)]; 
end
%shuffle auditory locations
rand_indices = [];
for i = 1:AudInfo.numTrialsPerLoc; rand_indices = [rand_indices, randperm(2,2)]; end

AudInfo.trialConditions = NaN(1,AudInfo.numTotalTrials*2);
AudInfo.trialConditions(ExpInfo.order_VSnAS==1) = AudInfo.Distance(rand_indices); 
AudInfo.trialConditions(ExpInfo.order_VSnAS==2) = Shuffle(AudInfo.Distance(rand_indices)); 

%1st row: location (in deg)
%2nd row: responses (in deg)
%3rd row: response time
AudInfo.data      = zeros(3,AudInfo.numTotalTrials);
AudInfo.data(1,:) = AudInfo.trialConditions(ExpInfo.order_VSnAS==1); %in deg
%create a matrix whose 1st column is initial position and 2nd column is final position
AudInfo.Location_Matrix = [[AudInfo.InitialLoc, AudInfo.trialConditions(1:end-1)]',...
                                 AudInfo.trialConditions'];
[AudInfo.locations_wMidStep,AudInfo.moving_locations_steps, AudInfo.totalSteps] =...
    randomPath2(AudInfo.Location_Matrix, ExpInfo); %1 midpoint, 2 steps
AudInfo.waitTime         = 0.5; 

%% make visual stimuli (gaussian blob) **** PULL AND CHANGE 
%scaling
VSinfo.standard                      = 0.4; % a ratio between 0 to 1 to be multipled by 255
pblack                               = 1/8; % set contrast to 1*1/8 for the "black" background, so it's not too dark and the projector doesn't complain
%define visual stimuli
VSinfo.Distance                      = linspace(26.7358,26.7358,16); %in deg
VSinfo.numLocs                       = length(VSinfo.Distance);
VSinfo.numFrames                     = 6;
%VSinfo.duration                      = VSinfo.numFrames * ifi;%s
VSinfo.width                         = 201; %(pixel) Increasing this value will make the cloud more blurry (arbituary value)
VSinfo.boxSize                       = 101; %This is the box size for each cloud (arbituary value)
%set the parameters for the visual stimuli
VSinfo.blackBackground               = pblack * ones(ScreenInfo.xaxis,ScreenInfo.yaxis);
VSinfo.transCanvas                   = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis);
x                                    = 1:1:VSinfo.boxSize; y = x;
VSinfo.x                             = x; VSinfo.y = y;
[X,Y]                                = meshgrid(x,y);
VSinfo.cloud1d                       = mvnpdf([X(:) Y(:)],[median(x) median(y)],...
[VSinfo.width 0; 0 VSinfo.width]);
pscale                               = (1-pblack)/max(VSinfo.cloud1d); % the max contrast of the blob adds the background contrast should <= 1
VSinfo.cloud1d                         = VSinfo.cloud1d .* pscale;
VSinfo.Cloud                         = VSinfo.standard.*reshape(VSinfo.cloud1d,length(x),length(y));
VSinfo.blk_texture                   = Screen('MakeTexture', windowPtr, VSinfo.blackBackground,[],[],[],2);

%shuffle visual locations
rand_indices = [];
for i = 1:VSinfo.numTrialsPerLoc; rand_indices = [rand_indices, randperm(4,4)]; end
VSinfo.trialConditions = VSinfo.initialDistance(rand_indices); 

%date_easyTrials stores all the data for randomly inserted easy trials
%1st row: the target will appear at either of the four locations (in deg)
%2nd row: the target location (in cm)
%3rd row: response (in deg)
%4th row: Response time
VSinfo.numTotalTrials = VSinfo.numTrialsPerLoc*VSinfo.numLocs;
VSinfo.data           = zeros(4,VSinfo.numTotalTrials);
VSinfo.data(1,:)      = VSinfo.trialConditions;
VSinfo.data(2,:)      = tan(deg2rad(VSinfo.data(1,:))).*ExpInfo.sittingDistance;
VSinfo.blk_texture    = Screen('MakeTexture', windowPtr, VSinfo.blackScreen,[],[],[],2);    

%% specify the experiment informations
ExpInfo.numBlocks         = 4;
blocks                    = linspace(0,AudInfo.numTotalTrials+VSinfo.numTotalTrials,...
                            ExpInfo.numBlocks+1); 
%split all the trials into 4 blocks
ExpInfo.breakTrials       = floor(blocks(2:(end-1)));
ExpInfo.numTrialsPerBlock = ExpInfo.breakTrials(1);

%% Run the experiment by calling the functions PresentAuditoryStimulus and PresentVisualStimulus
%start the experiment
DrawFormattedText(windowPtr, 'Press any button to start the unimodal localization task.',...
    'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,[255 255 255]);
Screen('Flip',windowPtr);
KbWait(-3); WaitSecs(1);
Screen('Flip',windowPtr);

for i = 1:(AudInfo.numTotalTrials+VSinfo.numTotalTrials) 
    if ExpInfo.order_VSnAS(i) == 1 %auditory trial
        jj = sum(ExpInfo.order_VSnAS(1:i)==1);
        [AudInfo.data(2,jj), AudInfo.data(3,jj)] = PresentAuditoryStimulus(i,...
            ExpInfo,ScreenInfo,AudInfo,motorArduino,noOfSteps,pahandle,windowPtr);
        
    else %visual trial
        ii = sum(ExpInfo.order_VSnAS(1:i)==2);
        [VSinfo.data(3,ii),VSinfo.data(4,ii)] = PresentVisualStimulus(i,...
            ii,ExpInfo,ScreenInfo,VSinfo,AudInfo,motorArduino,noOfSteps,...
            pahandle,windowPtr);
    end
    
    %add breaks     
    if ismember(i,ExpInfo.breakTrials)
        DrawFormattedText(windowPtr, 'You''ve finished one block. Please take a break.',...
            'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis-30,...
            [255 255 255]);
        DrawFormattedText(windowPtr, 'Press any button to resume the experiment.',...
            'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,...
            [255 255 255]);
        Screen('Flip',windowPtr); KbWait(-3); WaitSecs(1);
        Screen('Flip',windowPtr); WaitSecs(0.5);
    end  
end

%% Delete Arduino
fclose(Arduino);
delete(motorArduino)
ShowCursor;

%% Save data and end the experiment
Unimodal_localization_data = {ExpInfo,ScreenInfo,VSinfo,AudInfo};
save(out1FileName,'Unimodal_localization_data');
Screen('CloseAll');