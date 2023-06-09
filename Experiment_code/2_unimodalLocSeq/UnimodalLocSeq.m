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
    try ExpInfo.subjID = input('Please enter participant ID#: ') ; 
    catch
    end
end

%load the AV sequences with fixed correlations 
D = load('generatedAVseqs.mat');
ExpInfo.Atrain = D.generatedAVseqs{1,1};
ExpInfo.Vtrain = D.generatedAVseqs{1,2};
out1FileName   = ['UnimodalLocSeq_sub', num2str(ExpInfo.subjID)];

%% Screen Setup 
Screen('Preference', 'VisualDebugLevel', 1);
Screen('Preference', 'SkipSyncTests', 1);
% testing----------------------------------------------------
screens = Screen('Screens');
screenNumber = max(screens);
black = BlackIndex(screenNumber);
opacity = 0.7;
PsychDebugWindowConfiguration([], opacity)
[windowPtr, rect] = PsychImaging('OpenWindow', screenNumber, black);
% ------------------------------------------------------------
% [windowPtr,rect] = Screen('OpenWindow', 0, [1,1,1]);
% [windowPtr,rect] = Screen('OpenWindow', 0, [0,0,0],[100 100 1000 480]); % for testing
[ScreenInfo.xaxis, ScreenInfo.yaxis] = Screen('WindowSize',windowPtr);
Screen('TextSize', windowPtr, 35) ;   
Screen('TextFont',windowPtr,'Times');
Screen('TextStyle',windowPtr,1);  

[center(1), center(2)]     = RectCenter(rect);
ScreenInfo.xmid            = center(1); % horizontal center
ScreenInfo.ymid            = center(2); % vertical center
ScreenInfo.numPixels_perCM = 6.2;
ScreenInfo.liftingYaxis    = 270; 
ifi = Screen('GetFlipInterval', windowPtr);

%fixation locations
ScreenInfo.x1_lb = ScreenInfo.xmid-7; ScreenInfo.x2_lb = ScreenInfo.xmid-1;
ScreenInfo.x1_ub = ScreenInfo.xmid+7; ScreenInfo.x2_ub = ScreenInfo.xmid+1;
ScreenInfo.y1_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-1;
ScreenInfo.y1_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+1;
ScreenInfo.y2_lb = ScreenInfo.yaxis-ScreenInfo.liftingYaxis-7;
ScreenInfo.y2_ub = ScreenInfo.yaxis-ScreenInfo.liftingYaxis+7;

%% Initialise serial object
Arduino = serial('/dev/cu.usbmodemFD131','BaudRate',115200);  
% open for usage
fopen(Arduino);

%% Open speakers
PsychDefaultSetup(2);
InitializePsychSound
devices = PsychPortAudio('GetDevices');
our_device = devices(3).DeviceIndex;


%% Make auditory stimuli (GWN)
AudInfo.fs                  = 44100;
audioSamples                = linspace(1,AudInfo.fs,AudInfo.fs);
standardFrequency_gwn       = 10;
AudInfo.stimDura            = 0.1; 
AudInfo.tf                  = 400; 
AudInfo.intensity           = 0.65;
AudInfo.waitTime            = 0.5;
duration_gwn                = length(audioSamples)*AudInfo.stimDura;
timeline_gwn                = linspace(1,duration_gwn,duration_gwn);
sineWindow_gwn              = sin(standardFrequency_gwn/2*2*pi*timeline_gwn/AudInfo.fs); 
carrierSound_gwn            = randn(1, max(timeline_gwn));
AudInfo.intensity_GWN       = 15;
AudInfo.GaussianWhiteNoise  = [AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn;...
                                 AudInfo.intensity_GWN.*sineWindow_gwn.*carrierSound_gwn]; 
AudInfo.inBetweenGWN        = AudInfo.intensity*AudInfo.GaussianWhiteNoise; 
pahandle                    = PsychPortAudio('Open', our_device, [], [], [], 2);%open device

%% Make visual stimuli (gaussian blob)
VSinfo.scaling                       = 0.4; % a ratio between 0 to 1 to be multipled by 255
pblack                               = 1/8; % set contrast to 1*1/8 for the "black" background, so it's not too dark and the projector doesn't complain
VSinfo.numFrames                     = 6;
VSinfo.duration                      = VSinfo.numFrames * ifi;%s
VSinfo.width                         = 201; %(pixel) Increasing this value will make the cloud more blurry (arbituary value)
VSinfo.boxSize                       = 101; %This is the box size for each cloud (arbituary value)
% set the parameters for the visual stimuli
VSinfo.blackBackground               = pblack * ones(ScreenInfo.xaxis,ScreenInfo.yaxis) * 255;
VSinfo.transCanvas                   = zeros(ScreenInfo.xaxis,ScreenInfo.yaxis);
x                                    = 1:1:VSinfo.boxSize; y = x;
VSinfo.x                             = x; VSinfo.y = y;
[X,Y]                                = meshgrid(x,y);
cloud_temp                           = mvnpdf([X(:) Y(:)],[median(x) median(y)],...
                                       [VSinfo.width 0; 0 VSinfo.width]);
pscale                               = (1-pblack)/max(cloud_temp); % the max contrast of the blob adds the background contrast should <= 1
cloud_temp                           = cloud_temp .* pscale;
VSinfo.Cloud                         = VSinfo.scaling.*reshape(cloud_temp,length(x),length(y))*255;
VSinfo.blk_texture                   = Screen('MakeTexture', windowPtr, VSinfo.blackBackground,[],[],[],2);

%% Specify some experiment information
ExpInfo.sittingDistance              = 113.0;
ExpInfo.LRmostSpeakers2center        = 65.5;
ExpInfo.LRmostVisualAngle            = (180/pi) * atan(ExpInfo.LRmostSpeakers2center / ...
                                      ExpInfo.sittingDistance);
ExpInfo.stimLocs                     = linspace(-30,30,31); %in deg
ExpInfo.numLocs                      = length(ExpInfo.stimLocs);
ExpInfo.centroids                    = ExpInfo.stimLocs([4,9,14,19,24,29]);
ExpInfo.numCentroids                 = 6;
ExpInfo.numTrialsPerLoc              = 40; %2 for practice, 60 for the real experiment
AudInfo.numTotalTrialsA              = ExpInfo.numTrialsPerLoc * ExpInfo.numCentroids;
VSinfo.numTotalTrialsV               = ExpInfo.numTrialsPerLoc * ExpInfo.numCentroids;
                                  
% the order of presenting V/A (if 1: A; %if 2: V)
ExpInfo.order_VSnAS     = [];
for i = 1:AudInfo.numTotalTrialsA
    ExpInfo.order_VSnAS = [ExpInfo.order_VSnAS, randperm(2,2)]; 
end

% shuffle A/V centroid locations
rand_indicesA = []; %stores centroid indices 
for i = 1:ExpInfo.numTrialsPerLoc; rand_indicesA = [rand_indicesA, randperm(6)]; end
rand_indicesV = [];
for i = 1:ExpInfo.numTrialsPerLoc; rand_indicesV = [rand_indicesV, randperm(6)]; end

ExpInfo.trialConditions = NaN(2,AudInfo.numTotalTrialsA+VSinfo.numTotalTrialsV);
ExpInfo.trialConditions(1,ExpInfo.order_VSnAS==1) = ExpInfo.centroids(rand_indicesA); 
ExpInfo.trialConditions(1,ExpInfo.order_VSnAS==2) = ExpInfo.centroids(rand_indicesV);
ExpInfo.trialConditions(2,ExpInfo.order_VSnAS==1) = rand_indicesA; 
ExpInfo.trialConditions(2,ExpInfo.order_VSnAS==2) = rand_indicesV;

% define blocks and break trials
ExpInfo.numBlocks         = 4;
blocks                    = linspace(0,AudInfo.numTotalTrialsA+VSinfo.numTotalTrialsV,...
                            ExpInfo.numBlocks+1); 
% split all the trials into 4 blocks
ExpInfo.breakTrials       = floor(blocks(2:(end-1)));
ExpInfo.numTrialsPerBlock = ExpInfo.breakTrials(1);

%% Initialize data matrices
% Auditory data
%data matrix (double)
%1st row: centroid (in deg)
%2nd row: responses (in deg)
%3rd row: response time
AudInfo.data      = zeros(3,AudInfo.numTotalTrialsA);
AudInfo.data(1,:) = ExpInfo.trialConditions(1,ExpInfo.order_VSnAS==1); %in deg
%corresponding sequences drawn from ExpInfo.Atrain (cell) -> used for
%recency effect analysis
AudInfo.randSampleAtrain = cell(1,AudInfo.numTotalTrialsA);

% Visual data
%data matrix (double)
%1st row: target centroid (in deg)
%2nd row: target centroid (in cm)
%3rd row: response (in deg)
%4th row: response time
VSinfo.data             = zeros(4,VSinfo.numTotalTrialsV);
VSinfo.data(1,:)        = ExpInfo.trialConditions(1,ExpInfo.order_VSnAS==2); %in deg
VSinfo.data(2,:)        = tan(deg2rad(VSinfo.data(1,:))).*ExpInfo.sittingDistance;
%Corresponding sequences drawn from ExpInfo.Atrain (cell) -> used for
%recency effect analysis
VSinfo.randSampleVtrain = cell(1, VSinfo.numTotalTrialsV);

%% Run the experiment by calling the functions PresentAuditoryTrain and PresentVisualTrain
%start the experiment
HideCursor;
Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
DrawFormattedText(windowPtr, 'Press any button to start the unimodal localization task.',...
    'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,[255 255 255]);
Screen('Flip',windowPtr);
KbWait(-3); WaitSecs(1);
Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
Screen('Flip',windowPtr);

for i = 1:(AudInfo.numTotalTrialsA+VSinfo.numTotalTrialsV) 
    colidx = ExpInfo.trialConditions(2,i);
    if ExpInfo.order_VSnAS(i) == 1 %auditory trial
        jj = sum(ExpInfo.order_VSnAS(1:i)==1);
        %randomly sample one sequence from the corresponding col of ExpInfo.Atrain
        AudInfo.randSampleAtrain(jj) = randsample(ExpInfo.Atrain(:,colidx),1); 
        [AudInfo.data(2,jj), AudInfo.data(3,jj)] = PresentAuditoryTrain(i,jj,...
            ExpInfo,ScreenInfo,AudInfo,VSinfo,Arduino,pahandle,windowPtr);

    else %visual trial
        ii = sum(ExpInfo.order_VSnAS(1:i)==2);
        %randomly sample one sequence from the corresponding col of ExpInfo.Vtrain
        VSinfo.randSampleVtrain(ii) = randsample(ExpInfo.Vtrain(:,colidx),1); 
        [VSinfo.data(3,ii),VSinfo.data(4,ii)] = PresentVisualTrain(i,...
            ii,ExpInfo,ScreenInfo,VSinfo,windowPtr);
    end

    %add breaks     
    if ismember(i,ExpInfo.breakTrials)
        % black screen
        Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        DrawFormattedText(windowPtr, 'You''ve finished one block. Please take a break.',...
            'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis-30,...
            [255 255 255]);
        DrawFormattedText(windowPtr, 'Press any button to resume the experiment.',...
            'center',ScreenInfo.yaxis-ScreenInfo.liftingYaxis,...
            [255 255 255]);
        Screen('Flip',windowPtr); KbWait(-3); WaitSecs(1);
        Screen('DrawTexture',windowPtr, VSinfo.blk_texture,[],...
                [0,0,ScreenInfo.xaxis, ScreenInfo.yaxis]);
        Screen('Flip',windowPtr); WaitSecs(0.5);
    end

    Unimodal_localization_data = {ExpInfo,ScreenInfo,VSinfo,AudInfo};
    save(out1FileName,'Unimodal_localization_data');
end

%% Delete Arduino
fclose(Arduino);
delete(Arduino)
ShowCursor;

%% Save data and end the experiment
Unimodal_localization_data = {ExpInfo,ScreenInfo,VSinfo,AudInfo};
save(out1FileName,'Unimodal_localization_data');
Screen('CloseAll');
